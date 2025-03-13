//
//  FeedLoaderCacheDecorator.swift
//  EAM
//
//  Created by Denis Yaremenko on 12.03.2025.
//

import Foundation
import EFM
import EFMiOS

public final class FeedLoaderCacheDecorator: FeedLoader {
    
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load {  [weak self] result in
            // не подходит поскольку не вызывает комплишн и сработает только в случае .success
//            if let feed = try? result.get() {
//                self?.cache.saveIgnoringResult(feed)
//                completion(result)
//            }
            
            completion(result.map { feed in
                self?.cache.saveIgnoringResult(feed)
                return feed
            })
        }
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}
