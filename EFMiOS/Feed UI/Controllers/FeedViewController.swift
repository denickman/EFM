//
//  FeedViewController.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 10.03.2025.
//

import UIKit
import EFM
//
//public protocol FeedViewControllerDelegate {
//    func didRequestFeedRefresh()
//}
//
//public final class FeedViewController: UITableViewController {
//    
//    // MARK: - Properties
//    
//    @IBOutlet private(set) public var errorView: ErrorView?
//    
//    public var delegate: FeedViewControllerDelegate?
//    
//    private var tableModel = [FeedImageCellController]() {
//        didSet { tableView.reloadData() }
//    }
//    
//    private var loadingControllers = [IndexPath: FeedImageCellController]()
//
//    // MARK: - Lifecycle
//    
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//        refresh()
//    }
//    
//    public override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        tableView.sizeTableHeaderToFit()
//    }
//    
//    // MARK: - Methods
//    
//    @IBAction func refresh() {
//        delegate?.didRequestFeedRefresh()
//    }
//    
//    public func display(_ cellControllers: [FeedImageCellController]) {
//        loadingControllers = [:]
//        tableModel = cellControllers
//    }
//    
//    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
//        let controller = tableModel[indexPath.row]
//        loadingControllers[indexPath] = controller
//        return controller
//    }
//    
//    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
//        loadingControllers[indexPath]?.cancelLoad()
//        loadingControllers[indexPath] = nil
//    }
//}
//
//extension FeedViewController {
//    
//    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        tableModel.count
//    }
//    
//    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        cellController(forRowAt: indexPath).view(in: tableView)
//    }
//    
//    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cancelCellControllerLoad(forRowAt: indexPath)
//    }
//
//}
//
//extension FeedViewController: UITableViewDataSourcePrefetching {
//    
//    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
//        indexPaths.forEach { indexPath in
//            cellController(forRowAt: indexPath).preload()
//        }
//    }
//    
//    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
//        indexPaths.forEach(cancelCellControllerLoad)
//    }
//}
//
//extension FeedViewController: ResourceLoadingView {
//    public func display(_ viewModel: ResourceLoadingViewModel) {
//        refreshControl?.update(isRefreshing: viewModel.isLoading)
//    }
//}
//
//extension FeedViewController: ResourceErrorView {
//    public func display(_ viewModel: ResourceErrorViewModel) {
//        errorView?.message = viewModel.message
//    }
//}
