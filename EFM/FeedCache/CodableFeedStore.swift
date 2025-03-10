//
//  CodableFeedStore.swift
//  EFM
//
//  Created by Denis Yaremenko on 10.03.2025.
//

import Foundation

public final class CodableFeedStore {
    
    private struct Cache: Codable {
        let items: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            items.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        
        let id: UUID
        let description: String?
        let location: String?
        let url: URL
        
        init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
        
        var local: LocalFeedImage {
            .init(id: id, description: description, location: location, url: url)
        }
    }
    
    // MARK: - Properties
    
    private let storeURL: URL
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    
    // MARK: - Init
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
}

extension CodableFeedStore: FeedStore {
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let url = storeURL
        
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(Cache(items: feed.map(CodableFeedImage.init), timestamp: timestamp))
                try encoded.write(to: url)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func delete(completion: @escaping DeletionCompletion) {
        let url = storeURL
        
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: url.path) else {
                return completion(.success(()))
            }
            
            do {
                try FileManager.default.removeItem(at: url)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let url = storeURL
        
        queue.async {
            guard let data = try? Data(contentsOf: url) else {
                return completion(.success(.none))
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                let cache = try jsonDecoder.decode(Cache.self, from: data)
                completion(.success(CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)))
                
            } catch {
                completion(.failure(error))
            }
            
        }
    }
}
