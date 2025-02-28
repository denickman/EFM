//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 26.02.2025.
//

import Foundation
import EFM

public class FeedLoaderWithFallbackComposite: FeedLoader {
    
    private let primary: FeedLoader // FeedLoaderCacheDecorator
    private let fallback: FeedLoader // localFeedLoader
    
    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] result in
            
            switch result {
            case .success:
                completion(result)
                
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}
