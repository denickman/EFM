//
//  FeedImageDataCache.swift
//  EFM
//
//  Created by Denis Yaremenko on 12.03.2025.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Data, Error>
    func save(_ data: Data, url: URL, completion: @escaping (Result) -> Void)
}
