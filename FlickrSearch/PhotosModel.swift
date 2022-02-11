//
//  PhotosModel.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/11/22.
//

import Foundation


struct PhotoItem: Identifiable {
    var id: UUID = UUID()
    var imageURL: URL
    var title: String = "photo"
    var dateTakenString: String = ""
    var published: String = ""
    var author: String = ""

    init(_ url: URL, title: String = "") {
        imageURL = url
        self.title = title
    }
}


class PhotosModel: ObservableObject {
    @Published var photos: [PhotoItem] = []
    @Published var selected: PhotoItem?
    private var service: FlickrWebService
    private let dateFormatter: PhotoDateFormatting?
    
    func fetch(using term: String) {
        service.fetchPhotos(searchTerm: term) { [weak self] in
            switch $0 {
            case .success(let resp):
                print(resp.title, "\(resp.items.count)")
                
                var items: [PhotoItem] = []
                resp.items.forEach {
                    if let url = URL(string: $0.media.m) {
                        var item = PhotoItem(url, title: $0.title)
                        item.dateTakenString = self?.dateFormatter?.stringDateFromISODateString($0.dateTaken) ?? ""
                        item.published = self?.dateFormatter?.relativeStringDateFromDateString($0.published) ?? ""
                        item.author = String($0.author.split(separator: " ").last ?? "")
                        
                        items.append(item)
                    }
                }
                DispatchQueue.main.async { [weak self] in
                    self?.photos = items
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    //                Task {
    //                    await MainActor.run { [unowned items] in
    //                        self?.photos = items
    //                    }
    //                }

    
    init(_ service: FlickrWebService? = nil, dateFormatter: PhotoDateFormatting? = nil) {
        self.service = service ?? FlickrServiceHandler()
        self.dateFormatter = dateFormatter ?? PhotoDates()
    }
    
}

