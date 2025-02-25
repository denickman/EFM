//
//  FeedUIComposer.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 23.02.2025.
//

import UIKit
import EFM
import EFMiOS

public final class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {

        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        
        let feedController = makeFeedViewController(delegate: presentationAdapter, title: FeedPresenter.title)
        
        let imageLoaderDecorator = MainQueueDispatchDecorator(decoratee: imageLoader)
        
        let feedViewAdapter = FeedViewAdapter(controller: feedController, imageLoader: imageLoaderDecorator)
        
        let feedPresenter = FeedPresenter(
            feedView: feedViewAdapter,
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController)
        )
 
        presentationAdapter.presenter = feedPresenter
 
        return feedController
    }
    
    private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let ctrl = storyboard.instantiateInitialViewController() as! FeedViewController
        ctrl.delegate = delegate
        ctrl.title = title
        return ctrl
    }
}


