//
//  FeedUIComposer.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 10.03.2025.
//

import UIKit
import EFM

public final class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        
        let feedLoaderDecorator = MainQueueDispatchDecorator(feedLoader)
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoaderDecorator)

        let feedController = makeFeedViewController(delegate: presentationAdapter, title: FeedPresenter.title)
        
        let imageLoaderDecorator = MainQueueDispatchDecorator(imageLoader)
        let feedViewAdapter = FeedViewAdapter(controller: feedController, imageLoader: imageLoaderDecorator)
        
        let feedPresenter = FeedPresenter(loadingView: WeakRefVirtualProxy(feedController), feedView: feedViewAdapter, errorView: WeakRefVirtualProxy(feedController))
        
        presentationAdapter.presenter = feedPresenter
        
        return feedController
    }
    
    private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateViewController(identifier: "FeedViewController") as! FeedViewController
        feedViewController.delegate = delegate
        feedViewController.title = title
        return feedViewController
    }
}
