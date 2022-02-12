//
//  PhotosModel.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/11/22.
//

import Foundation


class PhotoItem: Identifiable {
    var id: UUID = UUID()
    var imageURL: URL?
    var title: String = "photo"
    var dateTakenString: String = ""
    var published: String = ""
    var author: String = ""
    
    init(with item: Item, dateTakenString: String = "", published: String = "") {
        if let url = URL(string: item.media.m) {
            imageURL = url
        }
        title = item.title
        if let range = item.author.range(of: "@flickr.com ") {
            author = String(item.author.suffix(from: range.upperBound))
            author = author.replacingOccurrences(of: "(\"", with: "")
            author = author.replacingOccurrences(of: "\")", with: "")
        } else {
            author = item.author
        }
        self.dateTakenString = dateTakenString
        self.published = published
    }
}


class PhotosModel: ObservableObject {
    @Published var photos: [PhotoItem] = []
    private let service: FlickrWebService?
    private let dateFormatter: PhotoDateFormatting?
    
    func fetch(using term: String) {
        service?.fetchPhotos(searchTerm: term) { [weak self] in
            switch $0 {
            case .success(let resp):
                print(resp.title, "\(resp.items.count)")
                let items = resp.items.map {
                    PhotoItem(with: $0,
                              dateTakenString: self?.dateFormatter?.stringDateFromISODateString($0.dateTaken) ?? "",
                              published: self?.dateFormatter?.relativeStringDateFromDateString($0.published) ?? "")
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.photos = items
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    init(_ service: FlickrWebService? = nil, dateFormatter: PhotoDateFormatting? = nil) {
        self.service = service ?? FlickrServiceHandler()
        self.dateFormatter = dateFormatter ?? PhotoDates()
    }
}
