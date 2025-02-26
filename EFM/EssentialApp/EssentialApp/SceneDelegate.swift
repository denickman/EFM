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

    var window: UIWindow?
    
    let localStoreURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite")

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
    
    func makeRemoteClient() -> HTTPClient {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }
}

