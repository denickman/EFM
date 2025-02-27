//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 26.02.2025.
//

import Foundation
import EFM

public final class FeedLoaderCacheDecorator: FeedLoader {
    
    private let decoratee: FeedLoader // remote feed loader
    private let cache: FeedCache // local feed loader
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            if let feed = try? result.get() {
                self?.cache.saveIgnoringResult(feed)
            }
            completion(result)
        }
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}
