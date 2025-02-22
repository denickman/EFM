//
//  LocalFeedLoader.swift
//  EFM
//
//  Created by Denis Yaremenko on 22.02.2025.
//

import Foundation

public final class LocalFeedLoader: FeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModels()))
                
            case let .failure(error):
                completion(.failure(error))
                
            case .success:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    typealias SaveResult = Swift.Result<Void, Error>
    
    func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.delete { [weak self] deletionResult in
            guard let self else { return }
            
            switch deletionResult {
            case .success:
                self.cache(feed, completion: completion)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func cache(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocals(), timestamp: currentDate()) { [weak self] InsertionResult in
            guard self != nil else { return }
            completion(InsertionResult)
        }
    }
}


extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        map {
            .init(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}

extension Array where Element == FeedImage {
    func toLocals() -> [LocalFeedImage] {
        map {
            .init(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}
