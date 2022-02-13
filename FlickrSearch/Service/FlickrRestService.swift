//
//  FlickrRestService.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/12/22.
//

import Foundation
import Combine

/**
 Processing URL Session Data Task Results with Combine
 Use a chain of asynchronous operators to receive and process data fetched from a URL.
 https://developer.apple.com/documentation/foundation/urlsession/processing_url_session_data_task_results_with_combine
 */

@available (iOS 15, *)
private extension FlickrNetworkWebServiceHandler {

    func fetchFlickrItems(_ url: URL) async throws -> FlickrPhotosResult {
        print(#function, url)
        let decoder = JSONDecoder()
        let (data, _) = try await URLSession.shared.data(from: url)
        let results = try decoder.decode(Flickr.self, from: data)
        return .success(results)
    }
    
    func fetchFlickrItemsErrorHandled(_ url: URL) async throws -> FlickrPhotosResult {
        print(#function, url)
        let decoder = JSONDecoder()
        let (data, urlResponse): (Data, URLResponse)
        do {
            (data, urlResponse) = try await URLSession.shared.data(from: url)

            guard let httpResponse = urlResponse as? HTTPURLResponse else {
//                throw URLError(.badServerResponse)
                throw FetchError.badresponse
//                return .failure(.badresponse)
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                print("error statuscode", httpResponse.statusCode)
                throw FetchError.statusCode
//                throw URLError(.badServerResponse)
//                return .failure(.statusCode)
            }
            
        } catch {
            return .failure(.error(error))
        }

        let results: FlickrResponse
        do {
            results = try decoder.decode(Flickr.self, from: data)
        } catch {
            return .failure(.parse)
        }
        
        return .success(results)
    }

}

/**
 A cancelling FlickrWebService Class that submits a url request and srtores the task in dataTask to cancel later if needed
 combin request with  a FlickrWebService api with completion result
 */
class FlickrNetworkWebServiceHandler: FlickrWebService {
    @available (iOS 15, *)
    func fetchFlickrPhotos(searchTerm: String) async throws -> FlickrPhotosResult {
        guard let url = flickrServiceURL(searchTerm: searchTerm) else {
            throw FetchError.malformedURL
//            return .failure(.malformedURL)
        }
        print(#function, url)
        let itemsFetchResult = try await fetchFlickrItems(url)
        return itemsFetchResult
    }
    
    func cancel() {
        cancellable?.cancel()
    }
    
    func fetchPhotos(searchTerm: String, completion: @escaping (Result<Flickr, FetchError>) -> ()) {
        guard let url = flickrServiceURL(searchTerm: searchTerm) else { return completion(.failure(.malformedURL)) }
        print(#function, url)
        
        fetchWebService(url, completion: completion)
        //        fetchWebServiceNetworkService(url, completion: completion)
        //        fetchWebServiceDataNetworkService(url, completion: completion)
    }
    
    private var cancellable: AnyCancellable?
    
    // This class implements
    
    private func fetchWebService(_ url: URL, completion: @escaping (Result<Flickr, FetchError>) -> ()) {
        print(#function, url)
        
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
                case .finished: break
                }
                print ("Received completion: \($0).")
            }, receiveValue: { response in
                completion(.success(response))
            })
    }
    
    // Uses general Network service
    
    private func fetchWebServiceNetworkService(_ url: URL, completion: @escaping (Result<Flickr, FetchError>) -> ()) {
        //        cancellable = fetchUsinNetworkService(url)
        cancellable = fetchUsinNetworkService_debug(url)
            .sink(receiveCompletion: {
                switch $0 {
                case .failure(let error):
                    completion(.failure(.error(error)))
                case .finished: break
                }
                print ("Received completion: \($0).")
            }, receiveValue: { response in
                completion(.success(response))
            })
    }
    
    // Uses general Data Network service
    
    private func fetchWebServiceDataNetworkService(_ url: URL, completion: @escaping (Result<Flickr, FetchError>) -> ()) {
        //        cancellable = fetchUsinDataNetworkService(url)
        cancellable = fetchUsinDataNetworkService_debug(url)
            .sink(receiveCompletion: {
                switch $0 {
                case .failure(let error):
                    completion(.failure(.error(error)))
                case .finished: break
                }
                print ("Received completion: \($0).")
            }, receiveValue: { response in
                completion(.success(response))
            })
    }
    
    private let dataService = DataNetworkService()
}

/// Data Network service usage

extension FlickrNetworkWebServiceHandler {
    /// uses Sample service general handler
    
    private func fetchUsinDataNetworkService(_ url: URL) -> AnyPublisher<Flickr, Error> {
        fetchDataUsinDataNetworkService(url)
            .decode(type: Flickr.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    private func fetchDataUsinDataNetworkService(_ url: URL) -> AnyPublisher<Data, DataNetworkService.APIError> {
        dataService.fetch(url: url)
    }
    
    /// debug versions
    
    private func fetchUsinDataNetworkService_debug(_ url: URL) -> AnyPublisher<Flickr, Error> {
        print(#function, url)
        return fetchDataUsinDataNetworkService_debug(url)
            .decode(type: Flickr.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    private func fetchDataUsinDataNetworkService_debug(_ url: URL) -> AnyPublisher<Data, DataNetworkService.APIError> {
        print(#function, url)
        return dataService.fetch(url: url)
    }
}

/// Network service usage

extension FlickrNetworkWebServiceHandler {
    /// uses general handler
    
    private func fetchUsinNetworkService(_ url: URL) -> AnyPublisher<Flickr, NetworkService.FailureReason> {
        NetworkService.request(url: url)
    }
    
    private func fetchUsinNetworkService_debug(_ url: URL) -> AnyPublisher<Flickr, NetworkService.FailureReason> {
        print(#function, url)
        return NetworkService.request(url: url)
    }
}





// MARK: sample retry service ServiceHandler not FlickrWebService

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
            .sink(receiveCompletion: {
                print("Received completion: \($0).")
            }, receiveValue: {
                print("Received data: \($0.data).")
            })
    }
}
