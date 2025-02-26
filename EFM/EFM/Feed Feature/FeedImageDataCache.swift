//
//  FeedImageDataCache.swift
//  EFM
//
//  Created by Denis Yaremenko on 26.02.2025.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
