//
//  FeedCache.swift
//  EFM
//
//  Created by Denis Yaremenko on 12.03.2025.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
