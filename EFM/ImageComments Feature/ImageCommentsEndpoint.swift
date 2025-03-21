//
//  ImageCommentsEndpoint.swift
//  EFM
//
//  Created by Denis Yaremenko on 21.03.2025.
//

import Foundation

public enum ImageCommentsEndpoint {
    
    case get(UUID)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case .get(let id):
            return baseURL.appendingPathComponent("/v1/image/\(id)/comments")
        }
    }
  
}
