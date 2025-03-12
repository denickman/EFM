//
//  FeedLoaderPresentationAdapter.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 11.03.2025.
//

import Foundation
import EFM
import EFMiOS

final class FeedLoaderPresentationAdapter {
    
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
}

extension FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            switch result {
                case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
