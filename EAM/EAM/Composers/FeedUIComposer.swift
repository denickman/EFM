//
//  FeedUIComposer.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 10.03.2025.
//

import UIKit
import EFM
import EFMiOS
import Combine

public final class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
    ) -> FeedViewController {
        
        let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(loader: {
            feedLoader()
                .dispatchOnMainQueue()
        })
        
        let feedController = makeFeedViewController(delegate: presentationAdapter, title: FeedPresenter.title)

        let feedViewAdapter = FeedViewAdapter(controller: feedController) { url in
            imageLoader(url)
                .dispatchOnMainQueue()
        }
        
        let feedPresenter = LoadResourcePresenter(
            resourceView: feedViewAdapter,
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: { feed in
                return FeedPresenter.map(feed)
            }
        )
        
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



/***
public static func feedComposedUsingLoadersWith(
    feedLoader: FeedLoader,
    imageLoader: FeedImageDataLoader
) -> FeedViewController {
    
    let feedLoaderDecorator = MainQueueDispatchDecorator(feedLoader)
    let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoaderDecorator)

    let feedController = makeFeedViewController(delegate: presentationAdapter, title: FeedPresenter.title)
    
    let imageLoaderDecorator = MainQueueDispatchDecorator(imageLoader)
    let feedViewAdapter = FeedViewAdapter(controller: feedController, imageLoader: imageLoaderDecorator)
    
    let feedPresenter = FeedPresenter(loadingView: WeakRefVirtualProxy(feedController), feedView: feedViewAdapter, errorView: WeakRefVirtualProxy(feedController))
    
    presentationAdapter.presenter = feedPresenter
    
    return feedController
}
***/
