//
//  CodableFeedStore.swift
//  EFM
//
//  Created by Denis Yaremenko on 22.02.2025.
//

import Foundation

public final class CodableFeedStore: FeedStore {
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            feed.map { $0.local }
        }
    }
 
    private struct CodableFeedImage: Codable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL
        
        var local: LocalFeedImage {
            .init(id: id, description: description, location: location, url: url)
        }
        
        init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
    }
    
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
                let data = try encoder.encode(cache)
                try data.write(to: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func delete(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(.success(()))
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        
        queue.async {
            
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(.none))
            }
            
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.success(.init(feed: cache.localFeed, timestamp: cache.timestamp)))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
