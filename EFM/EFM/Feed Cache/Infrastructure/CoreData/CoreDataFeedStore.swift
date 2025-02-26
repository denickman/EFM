//
//  CoreDataFeedStore.swift
//  EFM
//
//  Created by Denis Yaremenko on 23.02.2025.
//

import Foundation
import CoreData

public final class CoreDataFeedStore {
    
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL) throws {
        guard let model = CoreDataFeedStore.model else {
            throw LoadingError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: "FeedStore", model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw LoadingError.failedToLoadPersistentStores(error)
        }
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
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
    
}
