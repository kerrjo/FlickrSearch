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
                        Image(systemName: "photo")
                        ProgressView()
                    }
                } else {
                    Image(systemName: "photo.fill")
                }
                let title = item?.title ?? "unknown"
                let published = item?.published ?? ""
                let taken = item?.dateTakenString ?? ""
                let author = item?.author ?? ""
                
                VStack {
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
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView()
    }
}
