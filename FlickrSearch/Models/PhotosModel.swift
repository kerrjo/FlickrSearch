//
//  PhotosModel.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/11/22.
//

import Foundation

class PhotosModel: ObservableObject {
    @Published var photos: [PhotoItem] = []
    private let service: FlickrWebService?
    private let dateFormatter: PhotoDateFormatting?
    
    func fetch(using term: String) {
        service?.fetchPhotos(searchTerm: term) { [weak self] in
            switch $0 {
            case .failure(let error):
                print(error)

            case .success(let response):
                print(#function, response.title, "count", response.items.count)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.photos = self.itemsFromResponse(response)
                }
            }
        }
    }
    
    private func itemsFromResponse(_ response: FlickrResponse) -> PhotoItems {
        response.items.map {
            PhotoItem(with: $0,
                      dateTakenString: dateFormatter?.stringDateFromISODateString($0.dateTaken) ?? "",
                      published: dateFormatter?.relativeStringDateFromDateString($0.published) ?? "")
        }
    }
    
    init(_ service: FlickrWebService? = nil, dateFormatter: PhotoDateFormatting? = nil) {
        self.service = service ?? FlickrServiceHandler()
        self.dateFormatter = dateFormatter ?? PhotoDates()
    }
}
