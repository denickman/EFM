//
//  FeedImagePresenter.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 23.02.2025.
//

import Foundation
import EFM

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    
    private struct ImvalidImageDataError: Error {}
    
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel.init(description: model.description, location: model.location, image: nil, isLoading: true, shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: ImvalidImageDataError(), for: model)
        }
        
        view.display(FeedImageViewModel(description: model.description, location: model.location, image: image, isLoading: false, shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(.init(description: model.description, location: model.location, image: nil, isLoading: false, shouldRetry: true))
    }
    
    
}
