//
//  PhotosModel.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/11/22.
//

import Foundation
/*
 view model for photos search reaults
 */
class PhotosModel: ObservableObject {
    @Published var photos: [PhotoItem] = []
    private let service: FlickrWebService?
    private let dateFormatter: PhotoDateFormatting?
    
    func fetch(using term: String) {
        print(#function, term)
        if #available(iOS 15, *) {
            fetchAsync(using: term)
            //            fetchStandard(using: term)
        } else {
            fetchStandard(using: term)
        }
    }
    
    private func fetchStandard(using term: String) {
        service?.fetchPhotos(searchTerm: term) { [weak self] in
            switch $0 {
            case .failure(let error):
                print(error)
            case .success(let response):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.photos = self.itemsFromResponse(response)
                }
            }
        }
    }
    
    @available(iOS 15, *)
    private func fetchAsync(using term: String) {
        Task {
            let results = try await service?.fetchFlickrPhotos(searchTerm: term)
            switch results {
            case .failure(let error):
                print(error)
            case .success(let response):
                Task { @MainActor in self.photos = self.itemsFromResponse(response) }
            case .none:
                break
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
        self.service = service ?? FlickrNetworkWebServiceHandler() // FlickrServiceHandler()
        self.dateFormatter = dateFormatter ?? PhotoDates()
    }
}
