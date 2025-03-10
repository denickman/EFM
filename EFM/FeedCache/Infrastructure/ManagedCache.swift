//
//  ManagedCache.swift
//  EFM
//
//  Created by Denis Yaremenko on 10.03.2025.
//

import Foundation
import CoreData

class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

extension ManagedCache {
    
    static func find(in ctx: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try ctx.fetch(request).first
    }
    
    static func newUniqueInstance(in ctx: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: ctx).map(ctx.delete)
        return .init(context: ctx)
    }
    
    var localFeed: [LocalFeedImage] {
        return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
    }

}
