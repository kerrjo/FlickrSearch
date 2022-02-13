//
//  FlickrService.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/11/22.
//

import Foundation

enum FetchError: Error {
    case error(Error)
    case malformedURL
    case statusCode
    case parse
    case badresponseData
    case badresponse
    case notImplemented
}

typealias FlickrPhotosResult = Result<Flickr, FetchError>
typealias FlickrPhotosResultCompletion = (FlickrPhotosResult) -> ()

protocol FlickrWebService {
    func cancel()
    func fetchPhotos(searchTerm: String, completion: @escaping FlickrPhotosResultCompletion)
    func flickrServiceURL(searchTerm: String) -> URL?
    var itemsPerPage: Int { get }

    @available (iOS 15, *)
    func fetchFlickrPhotos(searchTerm: String) async throws -> FlickrPhotosResult
}

extension FlickrWebService {
    func flickrServiceURL(searchTerm: String) -> URL? {
        guard var components = URLComponents(string: "https://api.flickr.com/services/feeds/photos_public.gne") else { return nil }
        components.queryItems = [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1"),
            URLQueryItem(name: "tags", value: searchTerm)
        ]
        return components.url
    }
    
    // these params do not work
    // per_page=40
    // tagmode=any
    //    URLQueryItem(name: "per_page", value: "\(itemsPerPage)"),
    //    URLQueryItem(name: "tagmode", value: "any"),
    
    
    var itemsPerPage: Int { 30 }
}

@available (iOS 15, *)
extension FlickrWebService {
    func fetchFlickrPhotos(searchTerm: String) async throws -> FlickrPhotosResult {
        .failure(.notImplemented)
    }
}

/**
 https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags=porcupine
 URL to service
 https://api.flickr.com/services/feeds/photos_public.gne
 query params
 static  ?format=json
 static  &nojsoncallback=1
 dynamic &tags=porcupine
 */
