//
//  SceneDelegate.swift
//  EAM
//
//  Created by Denis Yaremenko on 11.03.2025.
//

import UIKit
import EFMiOS
import EFM
import CoreData
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Properties
    
    var window: UIWindow?
    
    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
    private lazy var navigationController = UINavigationController(
        rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalImageLoaderWithRemoteFallback,
            selection: showComments
        ))
    
    private var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("feed-store.sqlite"))
    }()
    
    //    private lazy var remoteFeedLoader: RemoteLoader = {
    //        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
    //        return .init(url: url, client: httpClient, mapper: FeedItemsMapper.map)
    //    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    // MARK: - Init
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    // MARK: - Lifecycle
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    // MARK: - Lifecycle
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

private extension SceneDelegate {
    //    private func makeRemoteFeedLoaderWithLocalFallback() -> FeedLoader.Publisher {
    //        remoteFeedLoader
    //            .loadPublisher()
    //            .caching(to: localFeedLoader)
    //            .fallback(to: localFeedLoader.loadPublisher)
    //    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<[FeedImage], Error> {
        
        let url = FeedEndpoint.get.url(baseURL: baseURL)
        
        return httpClient
            .getPublisher(url: url)
            .tryMap { (data, response) in // .tryMap результат стертого Future — AnyPublisher<[FeedImage], Error>.
                /// Combine работает как конвейер: каждый оператор обрабатывает результат предыдущего.
                ///  .tryMap изменяет тип Output с (Data, HTTPURLResponse) на [FeedImage].
                ///  .caching(to:) принимает [FeedImage] и добавляет побочный эффект (сохранение в кэш) через handleEvents.
                ///  handleEvents(receiveOutput:) срабатывает только если .tryMap завершился успешно (нет ошибки), потому что ошибки перехватываются раньше (например, в .fallback).
                try FeedItemsMapper.map(data, from: response)
            }
            .caching(to: localFeedLoader)
            .fallback {
                self.localFeedLoader.loadPublisher()
            }
        
        /// Option 2
        //        return httpClient
        //            .getPublisher(url: remoteURL) // side effect
        //            .delay(for: 2, scheduler: DispatchQueue.main)
        //            .tryMap(FeedItemsMapper.map) // pure function
        //            .caching(to: localFeedLoader) // side effect
        //            .fallback(to: localFeedLoader.loadPublisher)
    }
    
    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback {
                remoteImageLoader
                    .loadImageDataPublisher(from: url)
                    .caching(to: localImageLoader, using: url)
            }
    }
}

extension RemoteLoader: FeedLoader where Resource == [FeedImage] {
    /// since RemoteLoader `load` method has the same signature as FeedLoader-protocol `load` method, we do not need to apply it here
}

// MARK: - Comments Flow

extension SceneDelegate {
    /// #option 1
        private func showComments(for image: FeedImage) {
            let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
            let commentsCtrl = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: url))
            navigationController.pushViewController(commentsCtrl, animated: true)
        }
    
        private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
            /// Метод должен вернуть замыкание (() -> AnyPublisher), а не результат выполнения запроса сразу.
            /// Это позволяет отложить саму загрузку данных до момента, когда кто-то вызовет это замыкание.
            /// С [httpClient] ты захватываешь только то, что нужно — конкретный объект httpClient, минимизируя зависимости.
            return { [httpClient] in
                return httpClient
                    .getPublisher(url: url)
                    .tryMap(ImageCommentsMapper.map)
                    .eraseToAnyPublisher()
            }
        }
    
    /// #option 2
//    private func showComments(for image: FeedImage) {
//        let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
//        let commentsCtrl = CommentsUIComposer.commentsComposedWith(commentsLoader: { [unowned self] in
//            return self.makeRemoteCommentsLoader(url: url)
//        })
//        navigationController.pushViewController(commentsCtrl, animated: true)
//    }
//    
//    private func makeRemoteCommentsLoader(url: URL) -> AnyPublisher<[ImageComment], Error> {
//        httpClient
//            .getPublisher(url: url)
//            .tryMap(ImageCommentsMapper.map)
//            .eraseToAnyPublisher()
//    }
}

/*
 private extension SceneDelegate {
 
 func configureWindowInitialApproach() {
 let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
 
 let session = URLSession(configuration: .ephemeral)
 let client = URLSessionHTTPClient(session: session)
 
 let feedLoader = RemoteFeedLoader(url: url, client: client)
 let imageLoader = RemoteFeedImageDataLoader(client: client)
 
 let feedViewController = FeedUIComposer.feedComposedWith(feedLoader: feedLoader, imageLoader: imageLoader)
 
 window?.rootViewController = feedViewController
 window?.makeKeyAndVisible()
 }
 
 func configureWindow() {
 let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
 
 let remoteFeedLoader = RemoteFeedLoader(url: url, client: httpClient)
 let feedLoaderCacheDecorator = FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, cache: localFeedLoader)
 let feedLoaderFallback = FeedLoaderWithFallbackComposite(primary: feedLoaderCacheDecorator, fallback: localFeedLoader)
 
 let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
 let localImageLoader = LocalFeedImageDataLoader(store: store)
 let imageLoaderCacheDecorator = FeedImageDataLoaderCacheDecorator(decoratee: remoteImageLoader, cache: localImageLoader)
 let imageLoaderFallback = FeedImageDataLoaderWithFallbackComposite(primary: localImageLoader, fallback: imageLoaderCacheDecorator)
 
 let feedViewController = FeedUIComposer.feedComposedWith(feedLoader: feedLoaderFallback, imageLoader: imageLoaderFallback)
 
 window?.rootViewController = UINavigationController(rootViewController: feedViewController)
 window?.makeKeyAndVisible()
 }
 }
 */
