//
//  FeedImagePresenter.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 11.03.2025.
//

import Foundation

public final class FeedImagePresenter {
    public static func map(_ feed: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(description: feed.description, location: feed.location)
    }
}

/***
public protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}

public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    
    private struct InvalidImageDataError: Error {}
    
    private let view: View
    private let transformer: (Data) -> Image?
    
    public init(view: View, transformer: @escaping (Data) -> Image?) {
        self.view = view
        self.transformer = transformer
    }
    
    public func didStartLoadingImageData(for model: FeedImage) {
        view.display(
            .init(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: true,
                shouldRetry: false
            )
        )
    }
    
    public func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        let image = transformer(data)
        
        view.display(
            .init(
                description: model.description,
                location: model.location,
                image: image,
                isLoading: false,
                shouldRetry: image == nil
            )
        )
    }
    
    public func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(
            .init(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: false,
                shouldRetry: true
            )
        )
    }
    
}
***/
