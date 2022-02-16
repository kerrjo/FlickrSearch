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
    
    private var imageURL: URL
    
    @available(iOS 15, *)
    private func fetchImage() async {
        let imageData = try? Data(contentsOf: imageURL)
        Task { await MainActor.run { self.data = imageData ?? Data() } }
    }
    
    func load() {
        if #available(iOS 15, *) {
            Task { await fetchImage() }
        } else {
            URLSession.shared.dataTask(with: imageURL) { data, response, error in
                DispatchQueue.main.async { [weak self] in
                    self?.data = data ?? Data()
                }
            }.resume()
        }
    }
    
    init(withURL url: URL) { imageURL = url }
}
