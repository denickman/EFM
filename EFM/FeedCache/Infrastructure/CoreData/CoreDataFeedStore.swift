//
//  CoreDataFeedStore.swift
//  EFM
//
//  Created by Denis Yaremenko on 22.02.2025.
//

import Foundation
import CoreData

public final class CoreDataFeedStore {
     
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(container: NSPersistentContainer, context: NSManagedObjectContext) {
        self.container = container
        self.context = context
    }

    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context)  }
    }
}

extension CoreDataFeedStore: FeedStore {
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func delete(completion: @escaping DeletionCompletion) {
        do {
            try ManagedCache.find(in: context).map(context.delete).map(context.save)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    let cacheFeed = CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)
                    completion(.success(cacheFeed))
                } else {
                    completion(.success((.none)))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
}
