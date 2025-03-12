//
//  FeedPresenter.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 11.03.2025.
//

import Foundation

public protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

public final class FeedPresenter {
    
    public static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "title for the feed view")
    }
    
    public var feedLoadError: String {
        NSLocalizedString("FEED_VIEW_CONNECTION_ERROR", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    private let loadingView: FeedLoadingView
    private let feedView: FeedView
    private let errorView: FeedErrorView
    
    public init(loadingView: FeedLoadingView, feedView: FeedView, errorView: FeedErrorView) {
        self.loadingView = loadingView
        self.feedView = feedView
        self.errorView = errorView
    }
    
    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(.init(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(.init(feed: feed))
        loadingView.display(.init(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.init(message: feedLoadError))
        loadingView.display(.init(isLoading: false))
    }
    
}
