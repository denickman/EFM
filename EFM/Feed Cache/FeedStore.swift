//
//  FeedStore.swift
//  EFM
//
//  Created by Denis Yaremenko on 10.03.2025.
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
    
    typealias InsertionResult = Result<Void, Error>
    typealias DeletionResult = Result<Void, Error>
    typealias RetrievalResult = Result<CachedFeed?, Error>
    
    typealias InsertionCompletion = (InsertionResult) -> Void
    typealias DeletionCompletion = (DeletionResult) -> Void
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func delete(completion: @escaping DeletionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
  
}
