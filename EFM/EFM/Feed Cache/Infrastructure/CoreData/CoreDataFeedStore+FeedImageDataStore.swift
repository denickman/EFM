//
//  CoreDataFeedStore+FeedImageDataStore.swift
//  EFM
//
//  Created by Denis Yaremenko on 26.02.2025.
//

import Foundation
import CoreData

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
//        perform { context in
//            completion(Result {
//                try ManagedFeedImage.first(with: url, in: context)
//                    .map { $0.data = data }
//                    .map(context.save)
//            })
//        }
        perform { context in
            do {
                if let image = try ManagedFeedImage.first(with: url, in: context) {
                    image.data = data
                    try context.save()
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func retrieve(from url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
//        perform { context in
//            completion(Result {
//                try ManagedFeedImage.first(with: url, in: context)?.data
//            })
//        }
        
        perform { context in
            do {
                let data = try ManagedFeedImage.first(with: url, in: context)?.data
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
}
