//
//  CoreDataHelpers.swift
//  EFM
//
//  Created by Denis Yaremenko on 22.02.2025.
//

import CoreData

extension NSPersistentContainer {
    
    enum LoadingError: Swift.Error {
        case modelNotFound, failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        
        container.loadPersistentStores { description, error in
            if let error {
                loadError = error
            }
        }
        
        try loadError.map { error in
            throw LoadingError.failedToLoadPersistentStores(error)
        }
        
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        bundle.url(forResource: name, withExtension: "momd")
            .flatMap { url in
                return NSManagedObjectModel(contentsOf: url)
            }
    }
}
