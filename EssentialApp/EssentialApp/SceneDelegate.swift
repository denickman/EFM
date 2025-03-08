//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 13.02.2025.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("feed-store.sqlite"))
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
        
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)
        
        let feedLoaderCacheDecorator = FeedLoaderCacheDecorator(
            decoratee: remoteFeedLoader,
            cache: localFeedLoader
        )
        
        let feedLoaderFallback = FeedLoaderWithFallbackComposite(
            primary: feedLoaderCacheDecorator,
            fallback: localFeedLoader
        )
        
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)

        let imageLoderCacheDecorator = FeedImageDataLoaderCacheDecorator(
            decoratee: remoteImageLoader,
            cache: localImageLoader
        )
        
        let imageLoaderFallback = FeedImageDataLoaderWithFallbackComposite(
            primary: localImageLoader,
            fallback: imageLoderCacheDecorator
        )

        let feedViewCtrl = FeedUIComposer.feedComposedWith(
            feedLoader: feedLoaderFallback,
            imageLoader: imageLoaderFallback
        )
        
        window?.rootViewController = UINavigationController(rootViewController: feedViewCtrl)
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    /*
     func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
     guard let _ = (scene as? UIWindowScene) else { return }
     
     let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
     
     let session = URLSession(configuration: .ephemeral)
     let client = URLSessionHTTPClient(session: session)
     
     let feedLoader = RemoteFeedLoader(url: url, client: client)
     let imageLoader = RemoteFeedImageDataLoader(client: client)
     
     let feedViewController = FeedUIComposer.feedComposedWith(feedLoader: feedLoader, imageLoader: imageLoader)
     
     window?.rootViewController = feedViewController
     */
}
