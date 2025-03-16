//
//  FeedLoader.swift
//  EFM
//
//  Created by Denis Yaremenko on 10.03.2025.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping (Result) -> Void)
}
