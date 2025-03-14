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

public final class FeedImageCellController: FeedImageView {
   
    // MARK: - Properties
    
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    
    // MARK: - Init
    
    public init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }

    // MARK: - Methods
    
    public func display(_ viewModel: FeedImageViewModel<UIImage>) {
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        
        cell?.feedImageView.setImageAnimated(viewModel.image)
        
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
        cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delegate.didRequestImage
        
        /// accessibilityIdentifier for EssentialAppUIAcceptanceTests
        cell?.accessibilityIdentifier = "feed-image-cell"
        cell?.feedImageView.accessibilityIdentifier = "feed-image-view"
        
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }
    }
    
    public func preload() {
        delegate.didRequestImage()
    }
    
    public func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    func releaseCellForReuse() {
        cell?.onReuse = nil
        cell = nil
    }
}
