//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EFM
//
//  Created by Denis Yaremenko on 11.03.2025.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        perform { context in
            do {
                let managedFeedImage = try ManagedFeedImage.first(with: url, in: context)
                managedFeedImage?.data = data
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        perform { context in
            do {
                let managedFeedImage = try ManagedFeedImage.first(with: url, in: context)
                completion(.success(managedFeedImage?.data)) // completion(.success(.none))?????
            } catch {
                completion(.failure(error))
            }
        }
    }
    
}
