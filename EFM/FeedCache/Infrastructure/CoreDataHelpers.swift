//
//  CoreDataHelpers.swift
//  EFM
//
//  Created by Denis Yaremenko on 10.03.2025.
//

import CoreData

extension NSPersistentContainer {
    
    static func load(name: String, model: NSManagedObjectModel, url: URL) throws -> NSPersistentContainer {
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        
        container.loadPersistentStores { description, error in
            loadError = error
        }
        
        if let loadError = loadError {
            throw loadError
        }
        
        return container
    }
}

extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        bundle.url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}


/// Older load core data store flow
/*
 extension NSPersistentContainer {
 
 enum LoadingError: Swift.Error {
 case modelNotFound, failedToLoadStore(Swift.Error)
 }
 
 static func load(modelName name: String, url: URL, bundle: Bundle) throws -> NSPersistentContainer {
 guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
 throw LoadingError.modelNotFound
 }
 
 let description = NSPersistentStoreDescription(url: url)
 let container = NSPersistentContainer(name: name, managedObjectModel: model)
 container.persistentStoreDescriptions = [description]
 
 var loadError: Swift.Error?
 container.loadPersistentStores { loadError = $1 }
 
 try loadError.map { throw LoadingError.failedToLoadStore($0) }
 return container
 }
 
 }
 */


