//
//  FeedEndpoint.swift
//  EFM
//
//  Created by Denis Yaremenko on 21.03.2025.
//

import Foundation

public enum FeedEndpoint {
    case get
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return baseURL.appendingPathComponent("/v1/feed")
        }
    }
}
