//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 26.02.2025.
//

import Foundation
import EFM

public final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    
    private let decoratee: FeedImageDataLoader // RemoteFeedImageDataLoader
    private let cache: FeedImageDataCache // LocalFeedImageDataLoader
    
    public init(
        decoratee: FeedImageDataLoader,
        cache: FeedImageDataCache
    ) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            if case .success(let data) = result {
                self?.cache.saveIgnoringResult(data, for: url)
            }
            completion(result)
        }
    }
}

private extension FeedImageDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
}
