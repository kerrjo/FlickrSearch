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
        ScrollView {
            VStack {
                if let imageURL = item?.imageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
//                        Image(systemName: "photo")
//                            .resizable()
//                            .padding()
                        ProgressView()
                            .frame(width: 100, height: 100, alignment: .center)
                    }
                } else {
                    Image(systemName: "photo.fill")
                }
                
                let title = item?.title ?? "unknown"
                let published = item?.published ?? ""
                let taken = item?.dateTakenString ?? ""
                let author = item?.author ?? ""
                
                Text(title)
                    .font(.title)
                
                Divider()
                
                VStack {
                    Text("By")
                        .font(.body)
                    Text(author)
                        .font(.title2)
                }
                
                Spacer()
                
                Text("Published " + published)
                    .font(.caption)
                HStack {
                    Text("Date taken ")
                        .font(.body)
                    Text(taken)
                        .font(.caption)
                }
            }
        }
    }
}

struct PhotoView_Previews: PreviewProvider {
    
    static var previews: some View {
        PhotoView(
            item: PhotoItem(with: Item(
                title: "Picture This", link: "",
                media: Media(m: "https://live.staticflickr.com/65535/51830987906_a3cf10f042_m.jpg"),
                dateTaken: "", itemDescription: "", published: "",
                author: "nobody@flickr.com (\"joker\")", authorID: "", tags: ""))
        )
    }
}

//        var item = PhotoItem(
//            URL(string: "https://live.staticflickr.com/65535/51830987906_a3cf10f042_m.jpg")!,
//            title: "Picture This")
//        item.dateTakenString = "Fri Nov 3, 1986"
//        item.published = "2 days ago"

