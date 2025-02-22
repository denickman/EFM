//
//  FeedCache.swift
//  EFM
//
//  Created by Denis Yaremenko on 22.02.2025.
//

import Foundation

public struct CachedFeed {
    
    public let feed: [LocalFeedImage]
    public let timestamp: Date
    
    public init(feed: [LocalFeedImage], timestamp: Date) {
        self.feed = feed
        self.timestamp = timestamp
    }
}

public protocol FeedStore {
    
    typealias DeletionResult = Result<Void, Error>
    typealias InsertionResult = Result<Void, Error>
    typealias RetrievalResult = Result<CachedFeed?, Error>
    
    typealias DeletionCompletion = (DeletionResult) -> Void
    typealias InsertionCompletion = (InsertionResult) -> Void
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func delete(completion: @escaping DeletionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
