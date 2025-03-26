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
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>

    private init() {}
    
    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<Paginated<FeedImage>, Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        selection: @escaping (FeedImage) -> Void = { _ in }
    ) -> ListViewController {
        
        let presentationAdapter = FeedPresentationAdapter(
            loader: {
                feedLoader()
            }
        )
        
        let feedController = makeFeedViewController(title: FeedPresenter.title)
        
        feedController.onRefresh = presentationAdapter.loadResource
        
        let feedViewAdapter = FeedViewAdapter(controller: feedController) { url in
            imageLoader(url)
                .dispatchOnMainQueue()
        } selection: { feedImage in
            selection(feedImage)
        }
        
        let feedPresenter = LoadResourcePresenter(
            resourceView: feedViewAdapter,
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: { resource in
                return resource
            }
        )
        
        presentationAdapter.presenter = feedPresenter
        
        return feedController
    }
    
    private static func makeFeedViewController(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateViewController(identifier: "ListViewController") as! ListViewController
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
