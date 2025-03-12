//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 11.03.2025.
//

import Foundation
import EFM
import EFMiOS

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image> where View.Image == Image {
    
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    var presenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
}

extension FeedImageDataLoaderPresentationAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        let model = self.model
        
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
    
    
}
