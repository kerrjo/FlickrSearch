//
//  PhotoItemView.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/15/22.
//

import SwiftUI

/*
 a View contains a Image loaded from url if available otherwise place holder photo
 */
struct PhotoItemView : View {
    var item: PhotoItem?
    @Binding var square: Bool
    var padding = 0.0
    
    var imageURL: URL? {
        square ? item?.imageURLsquare : item?.imageURL
    }
    
    var body: some View {
        if #available(iOS 15, *) {
            
            PhotoItemImageAsyncImageView(imageURL: imageURL, padding: padding)
            
        } else {
            
            if let imageURL = imageURL {
                PhotoItemImageView(withURL: imageURL)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .accentColor(Color.white)
                    .scaleEffect(x: 1.3, y: 1.3, anchor: .center)
                    .padding(padding)
            }
            
        }
    }
}

/*
 a View contains a Image loaded from url if available otherwise place holder photo
 */
@available(iOS 15, *)
struct PhotoItemImageAsyncImageView : View {
    var imageURL: URL?
    var padding = 0.0
    var body: some View {
        if let imageURL = imageURL {
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
                    .progressViewStyle(.circular)
                    .accentColor(Color.white)
                    .scaleEffect(x: 1.3, y: 1.3, anchor: .center)
                    .padding(padding)
            }
        } else {
            Image(systemName: "photo.fill")
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fit)
        }
    }
}

/*
 a View loads an image and gets dimensions
 */
struct PhotoItemImageView: View {
    @ObservedObject var imageDataLoader: ImageDataLoader
    @State private var image: UIImage? = nil
    init(withURL url: URL?) {
        imageDataLoader = ImageDataLoader(withURL: url)
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
                self.image = UIImage(data: data) ?? UIImage()
            }
        }
    }
}


// 51861538056_63d8c1f0d6_m
// 51861538056_63d8c1f0d6_q
// 51861538056_63d8c1f0d6_z
// https://live.staticflickr.com/65535/51861538056_63d8c1f0d6_z.jpg
// https://live.staticflickr.com/65535/51861868789_8eb044c624_m.jpg

struct PhotoItemView_Previews: PreviewProvider {
    static var nameForImageURL: String = "51861538056_63d8c1f0d6_z"
    static var imageURLValid: URL? = Bundle.main.url(forResource: nameForImageURL, withExtension: "jpg")
    static var imageURLInvalid: URL? = Bundle.main.url(forResource: "invalid", withExtension: "jpg")
    @State static var square: Bool = true
    
    static var previews: some View {
        Group {
            PhotoItemView(
                item: PhotoItem(with: Item(title: "Picture This", link: "",
                                           media: Media(m: imageURLValid!.absoluteString), dateTaken: "", itemDescription: "", published: "",
                                           author: "", authorID: "", tags: ""),
                                dateTakenString: "",
                                published: ""),
                square: $square,
                padding: 10.0)
                .previewDisplayName("PhotoItemView")
            
            // TODO: broken
            //            PhotoItemView(
            //                item: PhotoItem(with: Item(title: "Picture This", link: "",
            //                                           media: Media(m: imageURLInvalid!.absoluteString), dateTaken: "", itemDescription: "", published: "",
            //                                           author: "", authorID: "", tags: ""),
            //                                dateTakenString: "",
            //                                published: ""),
            //                square: $square,
            //                padding: 10.0)
            //                .previewDisplayName("invalid url PhotoItemView")
        }
    }
}
