//
//  URLSessionHTTPClient.swift
//  EFM
//
//  Created by Denis Yaremenko on 23.02.2025.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    private struct UnexpectedError: Error {}
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { data, response, error in
            
            if let data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else if let error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedError()))
            }
        }
        .resume()
    }
    
}
