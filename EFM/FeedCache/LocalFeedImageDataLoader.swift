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
        
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(let data):
                if let data {
                    task.complete(with: .success(data))
                } else {
                    task.complete(with: .failure(LoadError.notFound))
                }
                
            case .failure:
                task.complete(with: .failure(LoadError.failed))
            }
        }
        
        return task
        
        /// option 2
//        task.complete(with: result
//            .mapError { _ in LoadError.failed }
//            .flatMap { data in
//                data.map { .success($0) } ?? .failure(LoadError.notFound)
//            })
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    
    private enum Error: Swift.Error {
        case failed
    }
    
    public func save(_ data: Data, url: URL, completion: @escaping (FeedImageDataCache.Result) -> Void) {
        store.insert(data, for: url) { [weak self] result in
            guard self != nil else { return }
            if case let .failure(error) = result {
                completion(.failure(Error.failed))
            }
            /// completion(result.mapError { _ in SaveError.failed })
        }
    }
}
