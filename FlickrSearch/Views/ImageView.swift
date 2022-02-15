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



struct ImageView_Previews: PreviewProvider {
    @State static var imageDimensionString: String = ""
    static var nameForImageURL: String = "51861538056_63d8c1f0d6_z"
    static var imageURLValid: URL? = Bundle.main.url(forResource: nameForImageURL, withExtension: "jpg")
    static var imageURLInvalid: URL? = Bundle.main.url(forResource: "invalid", withExtension: "jpg")
    
    static var previews: some View {
        Group {
            ImageView(withURL: imageURLValid, imageDimensionString: $imageDimensionString)
                .previewDisplayName("Valid url ImageView")
            
            ImageView(withURL: nil, imageDimensionString: $imageDimensionString)
                .previewDisplayName("nil url ImageView")
            
            ImageView(withURL: imageURLInvalid, imageDimensionString: $imageDimensionString)
                .previewDisplayName("invalid url ImageView")
        }
        .preferredColorScheme(.dark)
    }
}
