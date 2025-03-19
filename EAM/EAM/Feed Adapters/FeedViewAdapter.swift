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
        let cellControllers = viewModel.feed.map { model in
            
            let adapter = ImageDataPresentationAdapter { [imageLoader] in
                imageLoader(model.url)
            }
            
            let view = FeedImageCellController(viewModel: FeedImagePresenter.map(model), delegate: adapter)
            
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: { data in
                    return try UIImage.tryMake(data: data)
                }
            )
            
            return view
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
