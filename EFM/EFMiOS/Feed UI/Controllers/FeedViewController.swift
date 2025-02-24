//
//  FeedViewController.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 23.02.2025.
//

import UIKit

public final class FeedViewController: UITableViewController {
    
    var tableModels = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }
    
    private var refreshController: FeedRefreshController?
    
    convenience init(refreshController: FeedRefreshController) {
        self.init()
        self.refreshController = refreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self
        refreshControl = refreshController?.view
        refreshController?.refresh()
    }
    
    private func cellController(at indexPath: IndexPath) -> FeedImageCellController {
        tableModels[indexPath.row]
    }
    
}

extension FeedViewController {
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModels.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let view = cellController(at: indexPath).view()
        return view
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellController(at: indexPath).preload()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellController(at: indexPath).cancelLoad()
    }
}

extension FeedViewController: UITableViewDataSourcePrefetching {

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            cellController(at: $0).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            cellController(at: $0).cancelLoad()
        }
    }
}
