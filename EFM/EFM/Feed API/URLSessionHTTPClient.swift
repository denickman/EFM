//
//  URLSessionHTTPClient.swift
//  EFM
//
//  Created by Denis Yaremenko on 23.02.2025.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {

    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    private let session: URLSession
    private struct UnexpectedValueRepresentation: Error {}
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            
            if let data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else if let error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedValueRepresentation()))
            }
        }
 
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
    
}
