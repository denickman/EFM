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
import os

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Properties
    
    var window: UIWindow?
    
    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    private lazy var logger = Logger(subsystem: "com.yaremenko.denis.EAM", category: "main")
    
    // for not thread-safe operations & components
    private lazy var serialScheduler = DispatchQueue(label: "com.essentialdeveloper.infra.queue", qos: .userInitiated)
    
    // for thread-safe operations & components
    private lazy var concurrentScheduler = DispatchQueue(label: "com.essentialdeveloper.infra.queue", qos: .userInitiated, attributes: .concurrent)
    
    // Custom AnyScheduler type
    private lazy var customScheduler: AnyDispatchQueueScheduler = DispatchQueue(label: "com.essentialdeveloper.infra.queue", qos: .userInitiated, attributes: .concurrent).eraseToAnyScheduler()
 
    private lazy var navigationController = UINavigationController(
        rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalImageLoaderWithRemoteFallback,
            selection: showComments
        ))
    
    private lazy var httpClient: HTTPClient = {
        // без комбайна
        // HTTPClientProfilingDecorator(decoratee: URLSessionHTTPClient(session: URLSession(configuration: .ephemeral)), logger: logger)
        // с комбайном
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        do {
            return try CoreDataFeedStore(
                storeURL: NSPersistentContainer
                    .defaultDirectoryURL()
                    .appendingPathComponent("feed-store.sqlite"))
        } catch {
            //assertionFailure("Failed to instantiate CoreData store with error \(error)")
            logger.fault("Failed to instantiate CoreData store with error \(error)")
            return NullStore()
        }
    }()
    
    //    private lazy var remoteFeedLoader: RemoteLoader = {
    //        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
    //        return .init(url: url, client: httpClient, mapper: FeedItemsMapper.map)
    //    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    // MARK: - Init
    // for test purposes
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore, scheduler: AnyDispatchQueueScheduler) {
        self.init()
        self.httpClient = httpClient
        self.store = store
        self.customScheduler = scheduler
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
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
        makeRemoteFeedLoader()
            .caching(to: localFeedLoader) // side effect
            .fallback(to: localFeedLoader.loadPublisher)
            .map { feedImages in
                self.makeFirstPage(items: feedImages) // $0 - [FeedImage] from .tryMap(FeedItemsMapper.map)
            }
        //.map(makeFirstPage)
            .eraseToAnyPublisher()
        
        /// #Option 1 - Old Version
        //        return httpClient
        //            .getPublisher(url: url)
        //            .tryMap { (data, response) in // .tryMap результат стертого Future — AnyPublisher<[FeedImage], Error>.
        //                /// Combine работает как конвейер: каждый оператор обрабатывает результат предыдущего.
        //                ///  .tryMap изменяет тип Output с (Data, HTTPURLResponse) на [FeedImage].
        //                ///  .caching(to:) принимает [FeedImage] и добавляет побочный эффект (сохранение в кэш) через handleEvents.
        //                ///  handleEvents(receiveOutput:) срабатывает только если .tryMap завершился успешно (нет ошибки), потому что ошибки перехватываются раньше (например, в .fallback).
        //                try FeedItemsMapper.map(data, from: response)
        //            }
        //            .caching(to: localFeedLoader)
        //            .fallback {
        //                self.localFeedLoader.loadPublisher()
        //            }
        
        /// #Option 2 - Old Version
        //        return httpClient
        //            .getPublisher(url: remoteURL) // side effect
        //            .delay(for: 2, scheduler: DispatchQueue.main)
        //            .tryMap(FeedItemsMapper.map) // pure function
        //            .caching(to: localFeedLoader) // side effect
        //            .fallback(to: localFeedLoader.loadPublisher)
    }
    
    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        //let client = HTTPClientProfilingDecorator(decoratee: httpClient, logger: logger)
        //let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        // if your component is not thread-safe you need always execture operation in a serial queue (scheduler)
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .logCacheMisses(url: url, logger: logger)
            .fallback(to: { [httpClient, logger, customScheduler] in
                return httpClient
                    .getPublisher(url: url)
//                    .logErrors(url: url, logger: logger)
//                    .logElapsedTime(url: url, logger: logger)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
                    .subscribe(on: customScheduler)
                    .eraseToAnyPublisher()
            })
            // in order to not block MainQueue we subsribe localImageLoader results on another queue
            //.subscribe(on: DispatchQueue.global()) // concurrentQueue
            //.subscribe(on: serialScheduler) // serial Queue
            .subscribe(on: customScheduler) // concurrent Queue
           // no need to add  .receive(on: DispatchQueue.main) because PresentationAdapter already swith to MainQueue
            .eraseToAnyPublisher()
    }
}

// MARK: - LoadMore feature

extension SceneDelegate {
    
    private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
         makePage(items: items, last: items.last)
    }
    
    private func makePage(items: [FeedImage], last: FeedImage?) -> Paginated<FeedImage> {
        Paginated(
            items: items,
            loadMorePublisher: last != nil ? {
                return self.makeRemoteLoadMoreLoader(items: items, last: last)
            } : nil
        )
    }
    
    private func makeRemoteLoadMoreLoader(items: [FeedImage], last: FeedImage?) -> AnyPublisher<Paginated<FeedImage>, Error> {
        return makeRemoteFeedLoader(after: last)
            .map { newItems in // [FeedImage]
                (items + newItems, newItems.last) // ([FeedImage], feedImage)
            }
            .map(makePage) // pass ([FeedImage], feedImage)
        //            .delay(for: 2, scheduler: DispatchQueue.main)
        //            .flatMap { _ in
        //                Fail(error: NSError())
        //            }
            .caching(to: localFeedLoader)
    }
    
    private func makeRemoteFeedLoader(after image: FeedImage? = nil) -> AnyPublisher<[FeedImage], Error> {
        let url = FeedEndpoint.get(after: image).url(baseURL: baseURL)
        return httpClient
            .getPublisher(url: url)
            .tryMap { (data, response) in
                try FeedItemsMapper.map(data, from: response) // return [FeedItem]
            }
            .eraseToAnyPublisher()
    }
}

//extension RemoteLoader: FeedLoader where Resource == [FeedImage] {
//    /// since RemoteLoader `load` method has the same signature as FeedLoader-protocol `load` method, we do not need to apply it here
//}

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
