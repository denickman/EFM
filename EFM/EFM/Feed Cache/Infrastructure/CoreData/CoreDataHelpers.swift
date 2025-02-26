//
//  CoreDataHelpers.swift
//  EFM
//
//  Created by Denis Yaremenko on 23.02.2025.
//

import Foundation
import CoreData

extension NSPersistentContainer {

    static func load(name: String, model: NSManagedObjectModel, url: URL) throws -> NSPersistentContainer {
        
        let descriptions = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [descriptions]
        
        var loadError: Swift.Error?
        
        container.loadPersistentStores { _, error in
            loadError = error
        }
        
        if let error = loadError as? NSError {
            throw error
        }
        
        return container
    }
}

 extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { url in
                NSManagedObjectModel(contentsOf: url)
            }
    }
}
