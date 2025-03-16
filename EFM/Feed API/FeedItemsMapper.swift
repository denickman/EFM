//
//  FeedItemsMapper.swift
//  EFM
//
//  Created by Denis Yaremenko on 10.03.2025.
//

import Foundation

final class FeedItemsMapper {
    
    private struct Root: Decodable {
        var items: [RemoteFeedItem]
    }
    
    private static var IS_OK: Int { 200 }
    
    static func map(_ data: Data, response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == IS_OK,
                let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
    
}
