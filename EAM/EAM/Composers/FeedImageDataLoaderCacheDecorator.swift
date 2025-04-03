//
//  FeedImageDataLoaderCacheDecorator.swift
//  EAM
//
//  Created by Denis Yaremenko on 12.03.2025.
//

/*
import Foundation
import EFM

public final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            
            switch result {
            case .success(let data):
                self?.cache.saveIgnoringResult(data, url: url)
                completion(.success(data))
                
            case .failure(let error):
                completion(.failure(error))
            }
            //            completion(result.map { data in
            //                self?.cache.saveIgnoringResult(data, url: url)
            //                return data
            //            })
        }
    }
}


public extension FeedImageDataCache {
    func saveIgnoringResult(_ data: Data, url: URL) {
        try? save(data, for: url)
    }
}

*/
