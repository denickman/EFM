//
//  LocalFeedLoader.swift
//  EFM
//
//  Created by Denis Yaremenko on 10.03.2025.
//

import Foundation

public final class LocalFeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader: FeedCache {
    
    public typealias LoadResult = Swift.Result<[FeedImage], Error>
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(.some(let cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModels()))
                
            case .failure(let error):
                completion(.failure(error))
                
            case .success:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    
    public typealias SaveResult = Result<Void, Error>
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.delete { [weak self] deletionCompletion in
            guard let self else { return }
            
            switch deletionCompletion {
            case .success:
                self.cache(feed, completion: completion)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func cache(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] result in
            guard self != nil else { return }
            completion(result)
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        map {
            .init(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map {
            .init(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}


// MARK: - Feed Acceptance Tests
extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>

    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.delete(completion: completion)
                
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.delete(completion: completion)
                
            case .success:
                completion(.success(()))
            }
        }
    }
}
