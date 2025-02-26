//
//  FeedImageDataStore.swift
//  EFM
//
//  Created by Denis Yaremenko on 26.02.2025.
//

import Foundation

/// FeedImageDataStore is an abstraction to hide infrastructure details (e.g. coredata) from its client (LocalFeedImageDataLoader)
///

public protocol FeedImageDataStore {
    typealias InsertionResult = Swift.Result<Void, Error>
    typealias RetrievalResult = Swift.Result<Data?, Error>
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    func retrieve(from url: URL, completion: @escaping (RetrievalResult) -> Void)
}
