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
    
    public typealias SaveResult = Result<Void, Error>
    
    public enum SaveError: Error {
        case failed
    }
    
    public func save(_ data: Data, url: URL, completion: @escaping (SaveResult) -> Void) {
        completion(SaveResult {
            // Здесь используется инициализатор Result, который принимает замыкание где
            // Success — это тип возвращаемого значения (в данном случае Void, так как insert ничего не возвращает).
            // Error — это тип ошибки, которая может быть выброшена.
            
            //            Замыкание { try store.insert(data, for: url) }:
            //            Выполняет синхронный вызов store.insert(_:for:).
            //            Если insert завершается успешно, результатом будет .success(()) (успех с пустым значением Void).
            //            Если insert выбрасывает ошибку, результатом будет .failure(error) с этой ошибкой.
            
            try store.insert(data, for: url)
        }
            .mapError { _ in SaveError.failed }
        )
    }
}
    
