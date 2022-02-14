//
//  PhotoView.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/11/22.
//

import SwiftUI
import UIKit

struct PhotoView: View {
    var item: PhotoItem
    var title: String
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
                        .padding(.vertical, 10)

                    /*
                     uncomment in init PhotoItemImage Task { await fetchImage(url) }
                     */
                    
                    PhotoImageView(image: $photoImage.image)
                    
//                    PhotoImageAsyncImageView(imageURL: item.imageURLlarge)

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
struct PhotoImageView : View {
    @Binding var image: UIImage?

    var body: some View {
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

struct PhotoView_Previews: PreviewProvider {
    @State static var isBool = false
    @State static var image: UIImage? = UIImage(named:  "51830987906_a3cf10f042_z")
    static var currentBundle: Bundle = Bundle.main
    static var test_media = Media(m: currentBundle.url(forResource: "51851098944_7a65509216_z", withExtension: "jpg")!.absoluteString)
    static var imageURL: URL? = currentBundle.url(forResource: "51851098944_7a65509216_z", withExtension: "jpg")
    
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
                title: "hello",
                photoImage: PhotoItemImage(imageURL))
                .previewDisplayName("Detail View")
            
            PhotoImageAsyncImageView(imageURL: imageURL)
                .previewDisplayName("Image AsyncView")
            
            PhotoImageView(image: $image)
                .previewDisplayName("uiImage ImageView")
        }
        .preferredColorScheme(.dark)
    }
}
