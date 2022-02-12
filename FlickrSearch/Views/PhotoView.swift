//
//  PhotoView.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/11/22.
//

import SwiftUI

struct PhotoView: View {
    var item: PhotoItem?
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea([.bottom])
            
            ScrollView {
                VStack {
                    Text("Taken on " + (item?.dateTakenString ?? ""))
                        .colorInvert()
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    
                    if let imageURL = item?.imageURLlarge {
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
                    }
                    
                    let title = item?.title ?? "unknown"
                    let published = item?.published ?? ""
                    let author = item?.author ?? ""
                    
                    Group {
                        Text(title)
                            .font(.title)
                            .padding()
                        
                        Divider()
                        VStack {
                            Text("By")
                                .font(.subheadline)
                            Spacer()
                            Text(author)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        Text("Published " + published)
                            .font(.caption)
                            .padding()
                        
                    }
                    .colorInvert()
                } // Vstack
                .navigationTitle("Photo")
            }
        }
    }
}

struct PhotoView_Previews: PreviewProvider {
    
    static var previews: some View {
        PhotoView(
            item: PhotoItem(with: Item(
                title: "Picture This", link: "",
                media: Media(m: "https://live.staticflickr.com/65535/51830987906_a3cf10f042_c.jpg"),
                dateTaken: "Jan 18, 2000", itemDescription: "", published: "",
                author: "nobody@flickr.com (\"joker\")", authorID: "", tags: ""))
        )
    }
}

