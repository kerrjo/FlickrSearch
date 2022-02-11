//
//  PhotoView.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/11/22.
//

import SwiftUI

struct PhotoView: View {
    @ObservedObject var viewModel: PhotosModel

    var item: PhotoItem?
    var body: some View {
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
            //let title = viewModel.selected?.title ?? "unknown"
            let title = item?.title ?? "unknown"
            Text(title)
        }
    }
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView(viewModel: PhotosModel())
    }
}
