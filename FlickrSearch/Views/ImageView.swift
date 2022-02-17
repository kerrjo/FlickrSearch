//
//  ImageView.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/14/22.
//

import SwiftUI
import UIKit

/*
 a View loads an image and gets dimensions
 */
struct ImageView: View {
    @ObservedObject var imageDataLoader: ImageDataLoader
    @Binding var imageDimensionString: String
    @State private var image: UIImage? = nil
    @State private var didReceiveData: Bool = false
    var body: some View {
        Group {
            if let image = image {
                /// image found loaded and set
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if didReceiveData {
                /// image loaded not found
                Image(systemName: "questionmark.square")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.gray)
                    .padding(64)
            } else {
                /// image loading
                ProgressView()
                    .progressViewStyle(.circular)
                    .accentColor(Color.white)
                    .scaleEffect(x: 1.3, y: 1.3, anchor: .center)
                    .padding(64)
            }
        }
        .onAppear(perform: {
            if !didReceiveData {
                imageDataLoader.load()
            }
        })
        .onReceive(imageDataLoader.didChange) { data in
            if !didReceiveData {
                self.image = UIImage(data: data)
                if let image = self.image {
                    imageDimensionString = "width \(Int(image.size.width)) X height \(Int(image.size.height))"
                }
            }
            didReceiveData = true
        }
    }
    
    init(withURL url: URL, imageDimensionString: Binding<String>) {
        imageDataLoader = ImageDataLoader(withURL: url)
        self._imageDimensionString = imageDimensionString
    }
}

struct ImageView_Previews: PreviewProvider {
    @State static var imageDimensionString: String = ""
    static var nameForImageURL: String = "51861538056_63d8c1f0d6_m"
    static var imageURLValid: URL? = Bundle.main.url(forResource: nameForImageURL, withExtension: "jpg")
    static var imageURLUnavailable: URL? = URL(string: "file://zzz_m.zzz")
    static var previews: some View {
        Group {
            ImageView(withURL: imageURLValid!, imageDimensionString: $imageDimensionString)
                .previewDisplayName("valid url - ImageView")
            
            ImageView(withURL: imageURLUnavailable!, imageDimensionString: $imageDimensionString)
                .previewDisplayName("unavail url - ImageView")
        }
        .preferredColorScheme(.dark)
    }
}
