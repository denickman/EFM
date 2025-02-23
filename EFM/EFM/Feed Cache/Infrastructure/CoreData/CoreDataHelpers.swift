//
//  CoreDataHelpers.swift
//  EFM
//
//  Created by Denis Yaremenko on 23.02.2025.
//

import Foundation
import CoreData

extension NSPersistentContainer {
    
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let descriptions = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [descriptions]
        
        var loadError: Swift.Error?
        
        container.loadPersistentStores { _, error in
            loadError = error
        }
        
        if let error = loadError as? NSError {
            throw LoadingError.failedToLoadPersistentStores(error)
        }
        
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { url in
                NSManagedObjectModel(contentsOf: url)
            }
    }
}
