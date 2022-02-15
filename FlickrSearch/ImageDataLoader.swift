//
//  ImageDataLoader.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/15/22.
//

import UIKit
import Combine


/*
 Load data from url
 */

class ImageDataLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }
    
    private var imageURL: URL?
    
    @available(iOS 15, *)
    private func fetchImage(_ url: URL?) async {
        if let url = url, let imageData = try? Data(contentsOf: url) {
            print(#function, url)
            Task {
                await MainActor.run(body: {
                    self.data = imageData
                })
            }
        }
    }
    
    func load() {
        if #available(iOS 15, *) {
            Task { await fetchImage(imageURL) }
        } else {
            guard let url = imageURL else { return }
            print(#function, url)
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else { return }
                DispatchQueue.main.async {
                    self.data = data
                }
            }.resume()
        }
    }
    
    init(withURL url: URL?) {
        imageURL = url
    }
}

