//
//  ImageView.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/14/22.
//

import SwiftUI
import UIKit
import Combine

/*
 a View loads an image and gets dimensions
 */
struct ImageView: View {
    @ObservedObject var imageDataLoader: ImageDataLoader
    @Binding var imageDimensionString: String
    @State private var image: UIImage? = nil
    
    init(withURL url: URL?, imageDimensionString: Binding<String>) {
        imageDataLoader = ImageDataLoader(withURL: url)
        self._imageDimensionString = imageDimensionString
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.gray)
                    .padding(64)
            }
        }
        .onAppear(perform: {
            imageDataLoader.load()
        })
        .onReceive(imageDataLoader.didChange) { data in
            if image == nil {
                let image = UIImage(data: data) ?? UIImage()
                self.image = image
                imageDimensionString = "width \(Int(image.size.width)) X height \(Int(image.size.height))"
            }
        }
    }
}

/*
 Load data from url
 */

class ImageDataLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }
    
    private var imageURL: URL?
    
    @available(iOS 15, *)
    private func fetchImage(_ url: URL?) async {
        if let url = url, let imageData = try? Data(contentsOf: url) {
            print(#function, url)
            Task {
                await MainActor.run(body: {
                    self.data = imageData
                })
            }
        }
    }
    
    func load() {
        if #available(iOS 15, *) {
            Task { await fetchImage(imageURL) }
        } else {
            guard let url = imageURL else { return }
            print(#function, url)
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else { return }
                DispatchQueue.main.async {
                    self.data = data
                }
            }.resume()
        }
    }
    
    init(withURL url: URL?) {
        imageURL = url
    }
}


struct ImageView_Previews: PreviewProvider {
    @State static var imageDimensionString: String = ""
    @State static var image: UIImage? = UIImage(named: "51830987906_a3cf10f042_z")
    static var nameForImageURL: String = "51861538056_63d8c1f0d6_z"
    static var test_media = Media(m: Bundle.main.url(forResource: nameForImageURL, withExtension: "jpg")!.absoluteString)
    static var imageURL: URL? = Bundle.main.url(forResource: nameForImageURL, withExtension: "jpg")
    static var imageURLBad: URL? = Bundle.main.url(forResource: "invalid", withExtension: "jpg")
    
    static var previews: some View {
        Group {
            ImageView(withURL: imageURL, imageDimensionString: $imageDimensionString)
                .previewDisplayName("Valid url ImageView")
            
            ImageView(withURL: nil, imageDimensionString: $imageDimensionString)
                .previewDisplayName("nil url ImageView")
            
            ImageView(withURL: imageURLBad, imageDimensionString: $imageDimensionString)
                .previewDisplayName("invalid url ImageView")
        }
        .preferredColorScheme(.dark)
    }
}
