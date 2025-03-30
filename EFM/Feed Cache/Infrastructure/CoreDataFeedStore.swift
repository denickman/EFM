//
//  CoreDataFeedStore.swift
//  EFM
//
//  Created by Denis Yaremenko on 10.03.2025.
//

import CoreData

public final class CoreDataFeedStore {
    
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    public init(storeURL: URL) throws {
        
        guard let model = CoreDataFeedStore.model else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }
    
    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
    
}


























/// Old version of `CoreDataFeedStore`
/*

public final class CoreDataFeedStore: FeedStore {
    
    private let ctx: NSManagedObjectContext
    private let container: NSPersistentContainer
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, bundle: bundle)
        ctx = container.newBackgroundContext()
    }
    
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
        }
    }
    
    public func delete(completion: @escaping DeletionCompletion) {
        perform { ctx in
            do {
                try ManagedCache.find(in: ctx).map(ctx.delete).map(ctx.save)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { ctx in
            do {
                if let cache = try ManagedCache.find(in: ctx) {
                    completion(.success(CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)))
                } else {
                    completion(.success(.none))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        /// Вместо того чтобы в каждом методе дублировать ctx.perform { }, мы инкапсулируем эту логику в perform(_:)
        let context = self.ctx
        context.perform { action(context) }
    }
    
}
*/
