//
//  PhotoView.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/11/22.
//

import SwiftUI

struct PhotoView: View {
    var item: PhotoItem
    @ObservedObject var photoImage: PhotoItemImage
    
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
                        .padding(.vertical, 16)
                    
                    // Image get UIImage

                    /*
                     uncomment  in init PhotoItemImage
                     //Task { await fetchImage(url) }
                     
                     */
                            
//                    if let image = photoImage.image {
//                        Image(uiImage: image)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                    } else {
//                        Image(systemName: "photo")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .foregroundColor(Color.gray)
//                            .padding(64)
//                    }
                    
                    
                    // AsyncImage
                    
                    if let imageURL = item.imageURLlarge {
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
                    
                    Group {
                        Text(item.title)
                            .font(.title)
                        Divider()
                        VStack {
                            Text("By")
                                .font(.subheadline)
                            Spacer()
                            Text(item.author)
                                .font(.subheadline)
                        }
                        
                        Text("Published " + item.published)
                            .font(.caption)
                            .padding(.top, 8)

                        if photoImage.imageDimensionString.isEmpty {
                            Spacer()
                        } else {
                            Text(photoImage.imageDimensionString)
                                .font(.caption)
                                .padding(8)
                        }
                    }
                    .foregroundColor(Color.white)

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
                author: "nobody@flickr.com (\"joker\")", authorID: "", tags: "")),
            photoImage: PhotoItemImage()
            
        )
    }
}

