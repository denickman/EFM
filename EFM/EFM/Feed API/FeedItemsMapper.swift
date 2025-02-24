//
//  FeedItemsMapper.swift
//  EFM
//
//  Created by Denis Yaremenko on 23.02.2025.
//

import Foundation

final class FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    private static var OK_200: Int { 200 }
    
    static func map(_ data: Data, response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        
        do {
            let root = try? JSONDecoder().decode(Root.self, from: data)
            print(root?.items)
        } catch {
            print(error)
        }
        
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    } 
}
