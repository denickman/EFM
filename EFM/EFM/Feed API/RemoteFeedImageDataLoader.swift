//
//  RemoteFeedImageDataLoader.swift
//  EFM
//
//  Created by Denis Yaremenko on 25.02.2025.
//

import Foundation

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    
    // MARK: - HTTPClientTaskWrapper
    
    private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        
        var wrapped: HTTPClientTask? // HTTPClientSpy -> Task: HTTPClientTask
        
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
     
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        let task = HTTPClientTaskWrapper(completion)
        
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            /// flatMap позволяет вам выполнить сложную логику (например, проверку данных) и вернуть результат, который является типом результата для вашего запроса (например, .success или .failure).
            ///В отличие от обычного .map, .flatMap может работать с асинхронными операциями или возвращать значения, которые могут быть преобразованы в результат с типом Result.
            task.complete(with: result
                .mapError { _ in Error.connectivity }
                .flatMap { (data, response) in
                    let isValidResponse = response.isOK && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                })
        }
        return task
    }
}
