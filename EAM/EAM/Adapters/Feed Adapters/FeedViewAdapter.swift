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
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>

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
    
    func display(_ viewModel: Paginated<FeedImage>) {

        let feedSection: [CellController] = viewModel.items.map { feedItem in
            
            let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
                imageLoader(feedItem.url)
            })
                                                       
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(feedItem),
                delegate: adapter,
                selectionComplete: { [selection] in
                    selection(feedItem)
                })
            
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: UIImage.tryMake // data -> UIImage
            )
            
            return CellController(id: feedItem, view)
        }
        
        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller?.display(feedSection)
            return
        }
        
        let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
        let loadMoreController = LoadMoreCellController(callback: loadMoreAdapter.loadResource) // callback trigger adapter
        
        loadMoreAdapter.presenter = LoadResourcePresenter(
            resourceView: self,
            loadingView: WeakRefVirtualProxy(loadMoreController),
            errorView: WeakRefVirtualProxy(loadMoreController),
            mapper: { resource in
               // $0
                print("resource", resource)
                return resource
            }
        )
        
        let loadMoreSection = [CellController(id: UUID(), loadMoreController)]
 
        controller?.display(feedSection, loadMoreSection)
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
