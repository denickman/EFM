//
//  URLSessionHTTPClient.swift
//  EFM
//
//  Created by Denis Yaremenko on 10.03.2025.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {

    private struct UnexpectedValueRepresentation: Error {}
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(error))
            } else if let data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedValueRepresentation()))
            }
        }
        .resume()
    }
}
