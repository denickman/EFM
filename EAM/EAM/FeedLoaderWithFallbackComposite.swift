//
//  FeedLoaderWithFallbackComposite.swift
//  EAM
//
//  Created by Denis Yaremenko on 12.03.2025.
//

import Foundation
import EFM

public class FeedLoaderWithFallbackComposite: FeedLoader {

    private let primary: FeedLoader
    private let fallback: FeedLoader
    
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
