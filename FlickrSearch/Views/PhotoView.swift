//
//  PhotoView.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/11/22.
//

import SwiftUI
import UIKit
import Combine

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
                    
                    
                    // Image View UIImage
                    
                    ImageView(withURL: item.imageURLlarge, imageDimensionString: $imageDimensionString)
                    
                    
                    // AsyncImageView
                    
                    // PhotoImageAsyncImageView(imageURL: item.imageURLlarge)
                    
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
 a View contains a Image loaded from url if available
 otherwise place holder photo
 */
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
// 51830987906_a3cf10f042_z po
// 51861538056_63d8c1f0d6_z ss

struct PhotoView_Previews: PreviewProvider {
    @State static var isBool = false
    //@State static var image: UIImage? = UIImage(named: "51830987906_a3cf10f042_z")
    static var nameForImageURL: String = "51861538056_63d8c1f0d6_z"
    static var test_media = Media(m: Bundle.main.url(forResource: nameForImageURL, withExtension: "jpg")!.absoluteString)
    static var imageURL: URL? = Bundle.main.url(forResource: nameForImageURL, withExtension: "jpg")
    
    static var previews: some View {
        Group {
            PhotoView(
                item: PhotoItem(
                    with: Item(title: "Picture This", link: "",
                               media: test_media,
                               dateTaken: "Jan 18, 2000", itemDescription: "", published: "",
                               author: "nobody@flickr.com (\"joker\")", authorID: "", tags: ""),
                    dateTakenString: "Feb 2, 2020 at 2:00 pm",
                    published: "3 days ago"),
                title: "hello")
                .previewDisplayName("Detail View")
            
            PhotoImageAsyncImageView(imageURL: imageURL)
                .previewDisplayName("Image AsyncView")
        }
        .preferredColorScheme(.dark)
    }
}
