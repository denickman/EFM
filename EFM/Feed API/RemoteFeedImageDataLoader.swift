//
//  RemoteFeedImageDataLoader.swift
//  EFM
//
//  Created by Denis Yaremenko on 11.03.2025.
//

import Foundation

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    
    private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        var wrapped: HTTPClientTask?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            completion = nil
            wrapped?.cancel()
        }
    }

    public enum Error: Swift.Error {
        case connectivity, invalidData
    }
    
    // MARK: - Properties
    
    private let client: HTTPClient
    
    // MARK: - Init
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    // MARK: - Methods
    
    public  func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        let task = HTTPClientTaskWrapper(completion)
        
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            /// `option 1`
            switch result {
            case let .success((data, response)):
                let isValidResponse = response.isOK && !data.isEmpty
                
                if isValidResponse {
                    task.complete(with: .success(data))
                } else {
                    task.complete(with: .failure(Error.invalidData))
                }
                
            case .failure:
                task.complete(with: .failure(Error.connectivity))
            }
            
            /// `option 2`
            //            task.complete(with: result
            //                .mapError { _ in Error.connectivity }
            //                .flatMap { (data, response) in
            //                    let isValidResponse = response.isOK && !data.isEmpty
            //                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
            //                })
            //
        }
        return task
    }
}
