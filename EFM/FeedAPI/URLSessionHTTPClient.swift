//
//  URLSessionHTTPClient.swift
//  EFM
//
//  Created by Denis Yaremenko on 10.03.2025.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {

    private struct UnexpectedValueRepresentation: Error {}
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        
        let wrapped: URLSessionTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    // MARK: - Properties
    
    private let session: URLSession
    
    // MARK: - Init
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - HTTPClient
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(error))
            } else if let data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedValueRepresentation()))
            }
        }
        
        task.resume()
        
        return URLSessionTaskWrapper(wrapped: task)
    }
}
