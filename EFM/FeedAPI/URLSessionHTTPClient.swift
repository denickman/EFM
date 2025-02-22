//
//  URLSessionHTTPClient.swift
//  EFM
//
//  Created by Denis Yaremenko on 22.02.2025.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    private struct UnexpectedValueRepresentation: Error {}
    
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public func get(from url: URL, compleiton: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let data, let response = response as? HTTPURLResponse {
                compleiton(.success((data, response)))
            } else if let error {
                compleiton(.failure(error))
            } else {
                compleiton(.failure(UnexpectedValueRepresentation()))
            }
        }
    } 
}
