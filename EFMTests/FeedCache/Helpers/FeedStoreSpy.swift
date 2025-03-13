//
//  FeedStoreSpy.swift
//  EFMTests
//
//  Created by Denis Yaremenko on 12.03.2025.
//

import Foundation
import EFM

class FeedStoreSpy: FeedStore {
    
    enum ReceivedMessage {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrive
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletion = [InsertionCompletion]()
    private var retrievalCompletion = [RetrievalCompletion]()
    
    // MARK: - FeedStore
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletion.append(completion)
        receivedMessages.append(.insert(feed, timestamp))
    }
    
    func delete(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletion.append(completion)
        receivedMessages.append(.retrive)
    }
    
    // MARK: - Methods
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletion[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletion[index](.success(()))
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletion[index](.failure(error))
    }
    
    func completeRetrievalSuccessfully(feeds: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrievalCompletion[index](.success(.init(feed: feeds, timestamp: timestamp)))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletion[index](.success(.none))
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }
}
