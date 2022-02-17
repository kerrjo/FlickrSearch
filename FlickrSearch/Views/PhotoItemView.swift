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
    var imageURL: URL? { square ? item?.imageURLsquare : item?.imageURL }
    var body: some View {
        if let imageURL = imageURL {
            if #available(iOS 15, *) {
                PhotoItemImageAsyncImageView(imageURL: imageURL, padding: padding)
            } else {
                PhotoItemImageView(withURL: imageURL, padding: padding)
            }
        } else {
            Image(systemName: "questionmark.square")
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fit)
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
        AsyncImage(url: imageURL) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if phase.error != nil {
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
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


// 51861538056_63d8c1f0d6_m
// 51861868789_8eb044c624_m
// https://live.staticflickr.com/65535/51861538056_63d8c1f0d6_z.jpg
// https://live.staticflickr.com/65535/51861868789_8eb044c624_m.jpg

struct PhotoItemView_Previews: PreviewProvider {
    static var nameForImageURL: String = "51861868789_8eb044c624_m"
    static var imageURLValid: URL? = Bundle.main.url(forResource: nameForImageURL, withExtension: "jpg")
    static var imageURLUnavailable: URL? = URL(string: "file://zzz_m.zzz")
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
            
            PhotoItemView(
                item: PhotoItem(with: Item(title: "Picture This", link: "",
                                           media: Media(m: imageURLUnavailable!.absoluteString), dateTaken: "", itemDescription: "", published: "",
                                           author: "", authorID: "", tags: ""),
                                dateTakenString: "",
                                published: ""),
                square: $square,
                padding: 10.0)
                .previewDisplayName("invalid url PhotoItemView")
            
            PhotoItemView(
                item: PhotoItem(with: Item(title: "Picture This", link: "",
                                           media: Media(m: ""), dateTaken: "", itemDescription: "", published: "",
                                           author: "", authorID: "", tags: ""),
                                dateTakenString: "",
                                published: ""),
                square: $square,
                padding: 10.0)
                .previewDisplayName("nil url PhotoItemView")

        }
    }
}
