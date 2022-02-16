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
    @State private var didReceiveData: Bool = false
    
    init(withURL url: URL?, imageDimensionString: Binding<String>) {
        imageDataLoader = ImageDataLoader(withURL: url)
        self._imageDimensionString = imageDimensionString
    }
    
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
            } else {
                // already received
            }
            didReceiveData = true
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
