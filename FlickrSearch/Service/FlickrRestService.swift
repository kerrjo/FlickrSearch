//
//  FlickrRestService.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/12/22.
//

import Foundation
import Combine

/*
 https://stackoverflow.com/questions/58251478/what-is-the-best-way-to-handle-errors-in-combine
 Combine is strongly typed with respect to errors, so you must transform your errors to the correct type using mapError or be sloppy like RxSwift and decay everything to Error.
 */
enum NetworkService {
    enum FailureReason : Error {
        case sessionFailed(error: URLError)
        case decodingFailed
        case other(Error)
    }
    
    static func request<SomeDecodable: Decodable>(url: URL) -> AnyPublisher<SomeDecodable, FailureReason> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: SomeDecodable.self, decoder: JSONDecoder())
            .mapError({ error in
                switch error {
                case is Swift.DecodingError:
                    return .decodingFailed
                case let urlError as URLError:
                    return .sessionFailed(error: urlError)
                default:
                    return .other(error)
                }
            })
            .eraseToAnyPublisher()
    }
}


/**
 Processing URL Session Data Task Results with Combine
 Use a chain of asynchronous operators to receive and process data fetched from a URL.
  https://developer.apple.com/documentation/foundation/urlsession/processing_url_session_data_task_results_with_combine
 */

/**
 A cancelling FlickrWebService Class that submits a url request and srtores the task in dataTask to cancel later if needed
 combin request with  a FlickrWebService api with completion result
 */
class FlickrNetworkWebServiceHandler: FlickrWebService {
    func cancel() {
        cancellable?.cancel()
    }
    
    func fetchPhotos(searchTerm: String, completion: @escaping (Result<Flickr, FetchError>) -> ()) {
        guard let url = flickrServiceURL(searchTerm: searchTerm) else { return completion(.failure(.malformedURL)) }
        print(url)
        fetch(url, completion: completion)
    }
    
    private var cancellable: AnyCancellable?
    
    private func fetch(_ url: URL, completion: @escaping (Result<Flickr, FetchError>) -> ()) {
        cancellable = URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                          throw URLError(.badServerResponse)
                      }
                return element.data
            }
            .decode(type: FlickrResponse.self, decoder: JSONDecoder())
            .sink(receiveCompletion: {
                switch $0 {
                case .failure(let error):
                    completion(.failure(.error(error)))
                case .finished:
                    break
                }
                print ("Received completion: \($0).")
            },
                  receiveValue: { response in
                print ("Received user: \(response).")
                completion(.success(response))
            })
    }
}


/**
 A Combine publisher for Flikr request
 */

class FlickrNetworkServiceHandler {
    private(set) var dataTask: URLSessionDataTask?
    
    func flickrServiceURL(searchTerm: String) -> URL? {
        guard var components = URLComponents(string: "https://api.flickr.com/services/feeds/photos_public.gne") else { return nil }
        components.queryItems = [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1"),
            URLQueryItem(name: "tags", value: searchTerm)
        ]
        return components.url
    }

    private var cancellable: AnyCancellable?
    
    func fetchPhotos(searchTerm: String, completion: @escaping (Result<Flickr, FetchError>) -> ()) {
        guard let url = flickrServiceURL(searchTerm: searchTerm) else { return completion(.failure(.malformedURL)) }
        print(url)
        cancellable = fetch(url)
            .sink(receiveCompletion: {
                switch $0 {
                case .failure(let error):
                    completion(.failure(.error(error)))
                case .finished:
                    break
                }
                print ("Received completion: \($0).")
            },
                  receiveValue: { response in
                print ("Received user: \(response).")
                completion(.success(response))
                
            })
        
    }
    
    //            .sink(receiveCompletion: { print("Received completion: \($0).") },
    //                  receiveValue: { print("Received data: \($0.data).") })

    
    private func fetch(_ url: URL) -> AnyPublisher<Flickr, Error> {
        print(url)
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                          throw URLError(.badServerResponse)
                      }
                return element.data
            }
            .decode(type: Flickr.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
        
//            .sink(receiveCompletion: { print ("Received completion: \($0).") },
//                  receiveValue: { response in print ("Received user: \(response).")})
    }
}

/**
 Retry Transient Errors and Catch and Replace Persistent Errors
 Any app that uses the network should expect to encounter errors, and your app should handle them gracefully. Because transient network errors are fairly common, you may want to immediately retry a failed data task.
 
 */

class RetryNetworkServiceHandler {
    private var cancellable: AnyCancellable?
    private var fallbackUrlSession: URLSession { URLSession.shared }
    func fetch() {
        let url = URL(string: ":")!
        let fallbackURL = URL(string: ":")!

        let pub = URLSession.shared
            .dataTaskPublisher(for: url)
            .retry(1)
            .catch() { _ in
                self.fallbackUrlSession.dataTaskPublisher(for: fallbackURL)
            }
        cancellable = pub
            .sink(receiveCompletion: { print("Received completion: \($0).") },
                  receiveValue: { print("Received data: \($0.data).") })
    }
}
/*
 https://gist.github.com/stinger/7cb1a81facf7f846e3d53f60be34dd1e
 */

class SampleNetworkService {
    
    enum APIError: Error, LocalizedError {
        case unknown, apiError(reason: String)
        
        var errorDescription: String? {
            switch self {
            case .unknown:
                return "Unknown error"
            case .apiError(let reason):
                return reason
            }
        }
    }
    
    func fetch(url: URL) -> AnyPublisher<Data, APIError> {
        let request = URLRequest(url: url)
        
        return URLSession.DataTaskPublisher(request: request, session: .shared)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    throw APIError.unknown
                }
                return data
            }
            .mapError { error in
                if let error = error as? APIError {
                    return error
                } else {
                    return APIError.apiError(reason: error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}
 
