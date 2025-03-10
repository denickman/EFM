//
//  RemoteFeedLoader.swift
//  EFM
//
//  Created by Denis Yaremenko on 10.03.2025.
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
        client.get(from: url) { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
            case .success((let data, let response)):
                completion(RemoteFeedLoader.map(data, response: response))
  
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
        do {
            let feed = try FeedItemsMapper.map(data, response: response)
            return .success(feed.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        map {
            .init(id: $0.id, description: $0.description, location: $0.location, url: $0.image)
        }
    }
}
