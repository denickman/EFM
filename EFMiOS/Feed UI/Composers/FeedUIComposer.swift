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
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedController = FeedViewController(refreshController: refreshController)
        
        refreshController.onRefresh = { [weak feedController] feed in
            feedController?.tableModel = feed.map { feedItem in
                FeedImageCellController(model: feedItem, imageLoader: imageLoader)
            }
        }
        
        return feedController
    }
}
