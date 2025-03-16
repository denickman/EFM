//
//  CoreDataFeedStore+FeedStore.swift
//  EFM
//
//  Created by Denis Yaremenko on 11.03.2025.
//

import Foundation
import CoreData

extension CoreDataFeedStore: FeedStore {
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { ctx in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: ctx)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: ctx)
                try ctx.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
            
            //            Result {
            //                let managedCache = try ManagedCache.newUniqueInstance(in: context)
            //                managedCache.timestamp = timestamp
            //                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
            //                try context.save()
            //            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { ctx in
            
            do {
                if let managedCache = try ManagedCache.find(in: ctx) {
                    let cachedFeed = CachedFeed(feed: managedCache.localFeed, timestamp: managedCache.timestamp)
                    completion(.success(cachedFeed))
                } else {
                    completion(.success(.none))
                }
            } catch {
                completion(.failure(error))
            }
            
//            completion(Result {
//                try ManagedCache.find(in: ctx).map {
//                    CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
//                }
//            })
        }
    }
    
    public func delete(completion: @escaping DeletionCompletion) {
        perform { ctx in
            do {
                if let managedCache = try ManagedCache.find(in: ctx) {
                    ctx.delete(managedCache)
                    try ctx.save()
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
        
        //        Result {
        //            try ManagedCache.find(in: context).map(context.delete).map(context.save)
        //        }
    }
    
    
    
}
