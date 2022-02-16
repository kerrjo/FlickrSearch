//
//  PhotoView.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/11/22.
//

import SwiftUI

/*
 Detail PhotoView
 */
struct PhotoView: View {
    var item: PhotoItem
    var title: String
    @State private var imageDimensionString: String = ""
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea([.bottom])
            
            ScrollView {
                VStack {
                    Text("Taken on " + item.dateTakenString)
                        .foregroundColor(Color.gray)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    
                    if let imageURL = item.imageURLlarge {
                        if #available(iOS 15, *) {
                            // [ Image View UIImage ] obtains width and height
                            // ImageView(withURL: imageURL, imageDimensionString: $imageDimensionString)
                            
                            // [ AsyncImageView ]
                            PhotoImageAsyncImageView(imageURL: imageURL)
                        } else {
                            ImageView(withURL: imageURL, imageDimensionString: $imageDimensionString)
                        }
                   } else {
                        Image(systemName: "questionmark.square")
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                    }
                    
                    Group {
                        Text(item.title)
                            .font(.title)
                        Divider()
                        VStack {
                            Text("By")
                                .font(.subheadline)
                            
                            if #available(iOS 15, *) {
                                Spacer()
                            }
                            
                            Text(item.author)
                                .font(.subheadline)
                        }
                        Text("Published " + item.published)
                            .font(.caption)
                            .padding(.top, 8)
                        
                        Spacer()
                        
                        if imageDimensionString.isEmpty {
                            Spacer()
                        } else {
                            Text(imageDimensionString)
                                .font(.caption)
                                .padding(8)
                        }
                    }
                    .foregroundColor(Color.white)
                }
                .navigationTitle(title)
            }
        }
    }
}

/*
 a View contains a Image loaded from url if available otherwise place holder photo
 */
@available(iOS 15, *)
struct PhotoImageAsyncImageView : View {
    var imageURL: URL?
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
                    .accentColor(Color.gray)
                    .scaleEffect(x: 2, y: 2, anchor: .center)
                    .padding([.leading, .trailing], 10)
            }
        }
    }
}

// 51830987906_a3cf10f042_z po asset
// 51851098944_7a65509216_z po
// Seashells
// 51861868789_8eb044c624_m ss
// 51861538056_63d8c1f0d6_m ss

struct PhotoView_Previews: PreviewProvider {
    static var nameForImageURL: String = "51861868789_8eb044c624_m"
    static var imageURL: URL? = Bundle.main.url(forResource: nameForImageURL, withExtension: "jpg")
    static var imageURLUnavailable: URL? = URL(string: "file://zzz_m.zzz")
    static var previews: some View {
        Group {
            PhotoView(
                item: PhotoItem(with: Item(title: "Picture This", link: "",
                                           media: Media(m: imageURL!.absoluteString), dateTaken: "", itemDescription: "", published: "",
                                           author: "nobody@flickr.com (\"joker\")", authorID: "", tags: ""),
                                dateTakenString: "Feb 2, 2020 at 2:00 pm",
                                published: "3 days ago"),
                title: "hello")
                .previewDisplayName("DetailView")

            PhotoView(
                item: PhotoItem(with: Item(title: "Picture This", link: "",
                                           media: Media(m: imageURLUnavailable!.absoluteString), dateTaken: "", itemDescription: "", published: "",
                                           author: "nobody@flickr.com (\"joker\")", authorID: "", tags: ""),
                                dateTakenString: "Feb 2, 2020 at 2:00 pm",
                                published: "3 days ago"),
                title: "hello")
                .previewDisplayName("unavail url DetailView")
            
            PhotoView(
                item: PhotoItem(with: Item(title: "Picture This", link: "",
                                           media: Media(m: ""), dateTaken: "", itemDescription: "", published: "",
                                           author: "nobody@flickr.com (\"joker\")", authorID: "", tags: ""),
                                dateTakenString: "Feb 2, 2020 at 2:00 pm",
                                published: "3 days ago"),
                title: "hello")
                .previewDisplayName("nil url DetailView")

            if #available(iOS 15, *) {
                PhotoImageAsyncImageView(imageURL: imageURL)
                    .previewDisplayName("Image AsyncView")
            }
        }
        .preferredColorScheme(.dark)
    }
}
