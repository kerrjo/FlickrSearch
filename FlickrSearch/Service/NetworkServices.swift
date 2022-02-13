//
//  NetworkServices.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/13/22.
//

import Foundation
import Combine

/**
 Network services that generalized a url request
 1. NetworkService that uses a  Output = SomeDecodable
 2. DataNetworkService Output = Data
 */


/*
 a SomeDecodable NetworkService

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

/*
 a Data NetworkService
 https://gist.github.com/stinger/7cb1a81facf7f846e3d53f60be34dd1e
 */

class DataNetworkService {
    
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
 
