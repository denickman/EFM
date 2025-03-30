//
//  FeedImageCellController.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 10.03.2025.
//

import UIKit
import EFM

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class FeedImageCellController: NSObject {
    
    public typealias ResourceViewModel = UIImage
    
    // MARK: - Properties
    
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    private let viewModel: FeedImageViewModel
    private let selectionComplete: () -> Void
    // the only things that will change is <UIImage> that will come asyncronously from the backend
    
    // MARK: - Init
    
    public init(
        viewModel: FeedImageViewModel,
        delegate: FeedImageCellControllerDelegate,
        selectionComplete: @escaping () -> Void
    ) {
        self.delegate = delegate // adapter
        self.viewModel = viewModel
        self.selectionComplete = selectionComplete
    }
    
    // MARK: - Methods
    
    public func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }

    private func releaseCellForReuse() {
        cell?.onReuse = nil
        cell = nil
    }
    
}

extension FeedImageCellController:  ResourceView, ResourceLoadingView, ResourceErrorView {
    
    public func display(_ viewModel: UIImage) {
        cell?.feedImageView.setImageAnimated(viewModel)
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        cell?.feedImageRetryButton.isHidden = viewModel.message == nil
    }
}

extension FeedImageCellController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        
        // always use a memory debugger in order to find out leaking cause
        // due to potentian memory leak in FeedUIIntegrationTests we use a closure signature intead of equaling to delegate
        // cell?.onRetry = delegate.didRequestImage
        
        cell?.onRetry = { [weak self] in
            self?.delegate.didRequestImage()
        }
        
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }
        
        delegate.didRequestImage()
        
        /// accessibilityIdentifier for EssentialAppUIAcceptanceTests
        cell?.accessibilityIdentifier = "feed-image-cell"
        cell?.feedImageView.accessibilityIdentifier = "feed-image-view"
        
        return cell!
    }
    
    /// `cellForRowAt` be called a bunch of time ahead of time while `willDisplay` is only call when cell is about to be rendering
    ///  if you don't have a good estimated size you can move your logic to load expesive resources here (estimatedRowHeight)
    ///  if you have a good estimation you can do it in `cellForRow`
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {}
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        delegate.didRequestImage()
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelLoad()
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelLoad()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectionComplete()
    }
}
