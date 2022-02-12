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

protocol FlickrWebService {
    func cancel()
    func fetchPhotos(searchTerm: String, completion: @escaping (Result<Flickr, FetchError>) -> ())
    func flickrServiceURL(searchTerm: String) -> URL?
    var itemsPerPage: Int { get }
}

extension FlickrWebService {
    func flickrServiceURL(searchTerm: String) -> URL? {
        guard var components = URLComponents(string: "https://api.flickr.com/services/feeds/photos_public.gne") else { return nil }
        components.queryItems = [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1"),
            URLQueryItem(name: "per_page", value: "\(itemsPerPage)"),
            URLQueryItem(name: "tagmode", value: "any"),

            URLQueryItem(name: "tags", value: searchTerm)
        ]
        return components.url
    }
    
    var itemsPerPage: Int { 40 }
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
