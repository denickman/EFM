//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EFM
//
//  Created by Denis Yaremenko on 11.03.2025.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {

    public func insert(_ data: Data, for url: URL) throws { // если произойдёт ошибка, она будет выброшена,
         try performSync { context in
            Result {
                try ManagedFeedImage.first(with: url, in: context) // return managedFeedImage
                    .map { $0.data = data } // managedFeedImage.data
                    .map(context.save) // Если операция прошла успешно
            }
        }
    }
    
    public func retrieve(dataForURL url: URL) throws -> Data? {
        try performSync { context in
            Result {
                try ManagedFeedImage.data(with: url, in: context)
            }
        }
    }
}
