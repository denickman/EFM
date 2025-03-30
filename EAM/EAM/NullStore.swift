//
//  NullStore.swift
//  EAM
//
//  Created by Denis Yaremenko on 30.03.2025.
//

import Foundation
import EFM

// for neutral behaviour

class NullStore: FeedStore & FeedImageDataStore {
    func insert(_ feed: [EFM.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }
    
    func delete(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        completion(.success(()))
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
    
    
}
