//
//  PhotoView.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/11/22.
//

import SwiftUI

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
                    
                    if #available(iOS 15, *) {
                        // [ Image View UIImage ] obtains width and height
                        
                        // ImageView(withURL: item.imageURLlarge, imageDimensionString: $imageDimensionString)
                        
                        // [ AsyncImageView ]
                        
                        PhotoImageAsyncImageView(imageURL: item.imageURLlarge)
                    } else {
                        ImageView(withURL: item.imageURLlarge, imageDimensionString: $imageDimensionString)
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
        if let imageURL = imageURL {
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
                    .progressViewStyle(.circular)
                    .accentColor(Color.gray)
                    .scaleEffect(x: 2, y: 2, anchor: .center)
                    .padding([.leading, .trailing], 10)
            }
        } else {
            Image(systemName: "photo.fill")
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fit)
        }
    }
}

// 51861868789_8eb044c624_z ss
// 51830987906_a3cf10f042_z po asset
// 51861538056_63d8c1f0d6_z ss
// 51851098944_7a65509216_z po

struct PhotoView_Previews: PreviewProvider {
    static var nameForImageURL: String = "51851098944_7a65509216_z"
    static var imageURL: URL? = Bundle.main.url(forResource: nameForImageURL, withExtension: "jpg")
    static var previews: some View {
        Group {
            PhotoView(
                item: PhotoItem(with: Item(title: "Picture This", link: "",
                                           media: Media(m: imageURL!.absoluteString), dateTaken: "", itemDescription: "", published: "",
                                           author: "nobody@flickr.com (\"joker\")", authorID: "", tags: ""),
                                dateTakenString: "Feb 2, 2020 at 2:00 pm",
                                published: "3 days ago"),
                title: "hello")
                .previewDisplayName("Detail View")
            
            if #available(iOS 15, *) {
                PhotoImageAsyncImageView(imageURL: imageURL)
                    .previewDisplayName("Image AsyncView")
            }
        }
        .preferredColorScheme(.dark)
    }
}
