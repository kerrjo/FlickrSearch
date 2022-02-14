//
//  FlickrServiceHandler.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/11/22.
//

import Foundation

/**
 A cancelling FlickrWebService Class that submits a url request and srtores the task in dataTask to cancel later if needed
 
 */
class FlickrServiceHandler: FlickrWebService {
    private(set) var dataTask: URLSessionDataTask?

    func cancel() {
        guard let dataTask = dataTask else { return }
        dataTask.cancel()
        print(#function, "cancelled")
    }

    func fetchPhotos(searchTerm: String, completion: @escaping (Result<Flickr, FetchError>) -> ()) {
        guard let url = flickrServiceURL(searchTerm: searchTerm) else { return completion(.failure(.malformedURL)) }
        print(url)
        fetch(url, completion: completion)
    }
    
    private func fetch(_ url: URL, completion: @escaping (Result<Flickr, FetchError>) -> ()) {
        
        dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error { return completion(.failure(.error(error))) }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(.badresponse))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("error statuscode", httpResponse.statusCode)
                return completion(.failure(.statusCode))
            }
            
            guard let jsonData = data else { return completion(.failure(.badresponseData)) }
                                                               
            let jsonDecoder = JSONDecoder()
            do {
                let results = try jsonDecoder.decode(Flickr.self, from: jsonData)
                completion(.success(results))
            } catch {
                completion(.failure(.parse))
            }
        }
        dataTask?.resume()
    }
}


// MARK: as Future publisher

import Combine

/**
 A FlickrWebService Class that uses Future
 
 */
extension FlickrServiceHandler {
    func fetchPhotosPublisher(searchTerm: String) -> Future<Flickr, FetchError> {
        return Future { [weak self] promise in
            self?.fetchPhotos(searchTerm: searchTerm) {
                promise($0)
            }
        }
    }
}
