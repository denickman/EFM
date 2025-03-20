//
//  FeedViewAdapter.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 11.03.2025.
//

import UIKit
import EFM
import EFMiOS

final class FeedViewAdapter: ResourceView {
    
    // MARK: - Properties
    
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    public typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    
    // MARK: - Init
    
    init(controller: ListViewController? = nil, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    // MARK: - Methods
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            
            let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
                // partial application of a function
                // adapting completion with params (url) to compeltion with no params ()
                imageLoader(model.url)
            })
            
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter
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
        })
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
