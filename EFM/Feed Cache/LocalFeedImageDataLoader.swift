//
//  LocalFeedImageDataLoader.swift
//  EFM
//
//  Created by Denis Yaremenko on 12.03.2025.
//

import Foundation

public final class LocalFeedImageDataLoader {
    
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    
    public enum LoadError: Swift.Error {
        case failed, notFound
    }
    
    private final class LoadImageDataTask: FeedImageDataLoaderTask {
        
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = LoadImageDataTask(completion: completion)
        
        task.complete(with: Swift.Result {
            try store.retrieve(dataForURL: url)
        }
            .mapError {_ in LoadError.failed }
            .flatMap { data in
                data.map { .success($0)} ?? .failure(LoadError.notFound)
            }
        )
        return task
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
        
    public enum SaveError: Error {
        case failed
    }
    
    public func save(_ data: Data, for url: URL) throws {
        do {
            try store.insert(data, for: url)
        } catch {
            throw SaveError.failed
        }
    }
    
  
}
    
