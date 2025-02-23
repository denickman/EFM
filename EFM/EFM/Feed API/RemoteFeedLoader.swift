//
//  RemoteFeedLoader.swift
//  EFM
//
//  Created by Denis Yaremenko on 23.02.2025.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    
    public enum Error: Swift.Error {
        case connectivity, invalidData
    }
    
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success((let data, let response)):
                completion(RemoteFeedLoader.map(data, response: response))
                
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    public static func map(_ data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
        do {
            let items = try JSONDecoder().decode([RemoteFeedItem].self, from: data)
            return .success(items.toLocals())
        } catch {
            return .failure(error)
        }
    }
}

extension Array where Element == RemoteFeedItem {
     
    func toLocals() -> [FeedImage] {
        map {
            .init(id: $0.id, description: $0.description, location: $0.location, url: $0.image)
        }
    }
}
    
