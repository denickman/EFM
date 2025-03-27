//
//  RemoteLoader.swift
//  EFM
//
//  Created by Denis Yaremenko on 16.03.2025.
//

import Foundation

/*
public final class RemoteLoader<Resource> {
    
    // here you should be very careful, since you use your custom error, type `Result` think to use your `Error` type intead of system one
    public typealias Result = Swift.Result<Resource, Swift.Error> // [FeedImage], [Comment]
    public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    // MARK: - Properties
    
    private let url: URL
    private let client: HTTPClient
    private let mapper: Mapper
    
    public init(url: URL, client: HTTPClient, mapper: @escaping Mapper) {
        self.url = url
        self.client = client
        self.mapper = mapper
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success((let data, let response)):
                completion(self.map(data, from: response))
                
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            return .success(try mapper(data, response))
        } catch {
            return .failure(Error.invalidData)
        }
    }
    
}
*/
