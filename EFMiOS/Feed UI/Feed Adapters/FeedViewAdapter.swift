//
//  FeedViewAdapter.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 11.03.2025.
//

import UIKit
import EFM

final class FeedViewAdapter: FeedView {
    
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController? = nil, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
            controller?.tableModel = viewModel.feed.map { model in
                let adapter = FeedImageDataLoaderPresentationAdapter<FeedImageCellController, UIImage>(
                    model: model,
                    imageLoader: imageLoader
                )
                
                let view = FeedImageCellController(delegate: adapter)
                adapter.presenter = FeedImagePresenter(view: view, transformer: UIImage.init)
                return view
            }
        }
}
