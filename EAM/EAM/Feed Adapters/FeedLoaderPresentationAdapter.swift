//
//  FeedLoaderPresentationAdapter.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 11.03.2025.
//

import Foundation
import EFM
import EFMiOS
import Combine


final class FeedLoaderPresentationAdapter {
    
    var presenter: FeedPresenter?
    private var cancellable: Cancellable?
    private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
    
    init(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
        self.feedLoader = feedLoader
    }
}

extension FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.presenter?.didFinishLoadingFeed(with: error)
                }
            } receiveValue: { [weak self] feed in
                self?.presenter?.didFinishLoadingFeed(with: feed)
            }
    }
}


/***
 
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
***/


