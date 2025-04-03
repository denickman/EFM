//
//  FeedImageDataLoader.swift
//  EFM
//
//  Created by Denis Yaremenko on 11.03.2025.
//

import Foundation

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
