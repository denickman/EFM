//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 24.02.2025.
//

import Foundation
import EFM
import EFMiOS

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image> where View.Image == Image {
    
    var presenter: FeedImagePresenter<View, Image>?
    
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
}

extension FeedImageDataLoaderPresentationAdapter: FeedImageCellControllerDelegate {
    
    func didRequestImage() {
        let model = self.model
        presenter?.didStartLoadingImageData(for: model)
        
        // imageLoader.loadImageData -> FeedImageDataLoaderWithFallbackComposite
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            switch result {
            case .success(let data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
                
            case .failure(let error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
    
}
