//
//  PhotoItemImageView.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/16/22.
//

import SwiftUI

/*
 a View loads an image as UIImage
 */
struct PhotoItemImageView: View {
    @ObservedObject var imageDataLoader: ImageDataLoader
    @State private var image: UIImage? = nil
    @State private var didReceiveData: Bool = false
    var padding: Double
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
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
            } else {
                /// image loading
                ProgressView()
                    .progressViewStyle(.circular)
                    .accentColor(Color.white)
                    .scaleEffect(x: 1.3, y: 1.3, anchor: .center)
                    .padding(padding)
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
            }
            didReceiveData = true
        }
    }
    
    init(withURL url: URL, padding: Double = 0.0) {
        imageDataLoader = ImageDataLoader(withURL: url)
        self.padding = padding
    }
}

// 51861538056_63d8c1f0d6_m
// 51861868789_8eb044c624_m
struct PhotoItemImageView_Previews: PreviewProvider {
    static var nameForImageURL: String = "51861538056_63d8c1f0d6_m"
    static var imageURLValid: URL? = Bundle.main.url(forResource: nameForImageURL, withExtension: "jpg")
    static var imageURLUnavailable: URL? = URL(string: "file://zzz_m.zzz")
    @State static var square: Bool = true
    static var previews: some View {
        Group {
            PhotoItemImageView(withURL: imageURLValid!, padding: 10.0)
                .previewDisplayName("valid url ItemView")
            
            PhotoItemImageView(withURL: imageURLUnavailable!)
                .previewDisplayName("unavail url ItemView")
        }
    }
}
