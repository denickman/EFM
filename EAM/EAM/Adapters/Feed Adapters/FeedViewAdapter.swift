//
//  FeedViewAdapter.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 11.03.2025.
//

import UIKit
import EFM
import EFMiOS

/// Роль: Адаптирует данные от Presenter для ListViewController.
/// Бизнес-логика: Нет, только адаптация.
///
final class FeedViewAdapter: ResourceView {
    
    public typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>

    // MARK: - Properties
    
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private let selection: (FeedImage) -> Void
    
    // MARK: - Init
    
    init(
        controller: ListViewController? = nil,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        selection: @escaping (FeedImage) -> Void
    ) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }
    
    // MARK: - ResourceView
    
    func display(_ viewModel: FeedViewModel) {
        
        let cellControllers = viewModel.feed.map { model in
            
            let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
                // partial application of a function
                // adapting completion with params (url) to compeltion with no params ()
                imageLoader(model.url)
            })
            
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter,
                selectionComplete: { [selection] in
                    selection(model)
                }
            )
            
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: UIImage.tryMake
//                mapper: { data in
//                    guard let image = UIImage(data: data) else {
//                        throw InvalidImageData()
//                    }
//                    return image
//                }
            )
            
            /// since `model` is hashable and `id` is AnyHashable we can apply code like this
            return CellController(id: model, view) // data source, delegate, prefetching
        }
        
        controller?.display(cellControllers)
    }
}

extension UIImage {
    struct InvalidImageData: Error {}
    
    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        return image
    }
}
