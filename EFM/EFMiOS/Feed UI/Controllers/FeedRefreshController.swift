//
//  FeedRefreshController.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 23.02.2025.
//

import UIKit


protocol FeedRefreshControllerDelegate {
    func didRequestFeedRefresh()
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol LoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

final class FeedRefreshController: NSObject, LoadingView {
    
    private(set) lazy var view = loadView()
    private let delegate:FeedRefreshControllerDelegate
    
    init(delegate: FeedRefreshControllerDelegate) {
        self.delegate = delegate
    }
    
    @objc func refresh() {
        delegate.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return control
    }
    
}
