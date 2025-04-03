//
//  NullStore.swift
//  EAM
//
//  Created by Denis Yaremenko on 30.03.2025.
//
import Foundation
import EFM

// For neutral behaviour

class NullStore: FeedStore & FeedImageDataStore {
    
    func insert(_ data: Data, for url: URL) throws {
        // do not do anything, provide a neutral implementation
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        .none
    }
    
    func delete(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
}


