//
//  FeedImageDataLoader.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 23.02.2025.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(
        for url: URL,
        completion: @escaping (Result) -> Void
    ) -> FeedImageDataLoaderTask
}
