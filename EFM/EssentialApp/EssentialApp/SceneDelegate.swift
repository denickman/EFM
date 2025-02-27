//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Denis Yaremenko on 25.02.2025.
//

import UIKit
import EFM
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    typealias Store = FeedStore & FeedImageDataStore

    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()

    private lazy var store: Store = {
        try! CoreDataFeedStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("feed-store.sqlite"))
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    convenience init(httpClient: HTTPClient, store: Store) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        configureWindow()
    }
    
    func configureWindow() {
        let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
        
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)
        
        let feedLoaderCacheDecorator = FeedLoaderCacheDecorator(
            decoratee: remoteFeedLoader,
            cache: localFeedLoader
        ) // гарантирует, что загруженные из сети данные будут сохранены в кэше.
        
        let feedLoaderFallback = FeedLoaderWithFallbackComposite(
            primary: feedLoaderCacheDecorator,
            fallback: localFeedLoader
        ) // если нет интернета, данные будут загружены из кэша.
        
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)

        let imageLoderCacheDecorator = FeedImageDataLoaderCacheDecorator(
            decoratee: remoteImageLoader,
            cache: localImageLoader
        )
        
        let imageLoaderFallback = FeedImageDataLoaderWithFallbackComposite(
            primary: localImageLoader, // Сначала пытается загрузить изображение из локального кеша
            fallback: imageLoderCacheDecorator // Если в кэше нет изображения, запрашивает его у сети через
        )

        let feedViewCtrl = FeedUIComposer.feedComposedWith(
            feedLoader: feedLoaderFallback,
            imageLoader: imageLoaderFallback
        )
        
        window?.rootViewController = UINavigationController(rootViewController: feedViewCtrl)
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
  
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
/*
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let currentScene = (scene as? UIWindowScene) else { return }
        
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!

        let session = URLSession(configuration: .ephemeral)
        let client = makeRemoteClient() // URLSessionHTTPClient(session: session)
        
        let feedLoader = RemoteFeedLoader(url: url, client: client)
        let imageLoader = RemoteFeedImageDataLoader(client: client)

        let feedViewController = FeedUIComposer.feedComposedWith(feedLoader: feedLoader, imageLoader: imageLoader)
        
        // Создаём окно и устанавливаем корневой контроллер
            let window = UIWindow(windowScene: currentScene)
            window.rootViewController = feedViewController
            window.makeKeyAndVisible()
            self.window = window
    }
 */

}

