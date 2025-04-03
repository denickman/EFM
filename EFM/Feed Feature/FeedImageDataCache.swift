//
//  FeedImageDataCache.swift
//  EFM
//
//  Created by Denis Yaremenko on 12.03.2025.
//

import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}
