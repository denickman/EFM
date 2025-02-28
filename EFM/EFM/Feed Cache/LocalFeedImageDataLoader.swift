//
//  LocalFeedImageDataLoader.swift
//  EFM
//
//  Created by Denis Yaremenko on 26.02.2025.
//

import Foundation

public final class LocalFeedImageDataLoader {
    
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    
    public typealias SaveResult = Result<Void, Error>
    
    public enum SaveError: Error {
        case failed
    }
    
    public func save(
        _ data: Data,
        for url: URL,
        completion: @escaping (SaveResult) -> Void
    ) {
        store.insert(data, for: url) { [weak self] result in
            guard self != nil else { return }
            completion(result.mapError({ _ in
                SaveError.failed
            }))
        }
    }
    
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    
    // MARK: - LoadImageDataTask
    private final class LoadImageDataTask: FeedImageDataLoaderTask {
        
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public typealias LoadResult = FeedImageDataLoader.Result
    
    public enum LoadError: Error {
        case failed, notFound
    }
    
    public func loadImageData(
        from url: URL,
        completion: @escaping (LoadResult) -> Void
    ) -> FeedImageDataLoaderTask {
        let task = LoadImageDataTask(completion)
        
        store.retrieve(from: url) { [weak self] result in // Result<Data?, Error> либо Data?, либо Error.
            guard self != nil else { return }
            
            let mappedResult: LoadResult = result
                .mapError { _ in // преобразует ошибку (Error) в другую ошибку.
                    LoadError.failed
                }
                .flatMap { data in
                    /// data != nil, мы оборачиваем его в Result.success(data).
                    /// data == nil, возвращаем .failure(LoadError.notFound).
                    /// `data.map(Result.success)` is equal to `data != nil ? .success(data!) : nil`
                    data.map(Result.success) ?? .failure(LoadError.notFound)
                }
            
            task.complete(with: mappedResult)
        }
        return task
    }
}
