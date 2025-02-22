//
//  FeedItemsMapper.swift
//  EFM
//
//  Created by Denis Yaremenko on 22.02.2025.
//

import Foundation

final class FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    private static var IS_OK: Int { 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == IS_OK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
