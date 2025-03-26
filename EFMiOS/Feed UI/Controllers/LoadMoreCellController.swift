//
//  LoadMoreCellController.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 24.03.2025.
//

import UIKit
import EFM

public class LoadMoreCellController: NSObject, UITableViewDataSource {
    
    private let cell = LoadMoreCell()
    private var callback: () -> Void
    private var offsetObserver: NSKeyValueObservation?
    
    public init(callback: @escaping () -> Void) {
        self.callback = callback
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell.selectionStyle = .none
        return cell // we do need to reuse, only 1 cell
    }
    
    private func reloadIfNeeded() {
        print(">> cell is loading \(cell.isLoading)")
        guard !cell.isLoading else { return }
        print(">> CALLBACK!")
        callback()
    }
}

// MARK: - UITableViewDelegate

extension LoadMoreCellController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print(">> will display cell CHILD")
        reloadIfNeeded()
        
        offsetObserver = tableView.observe(\.contentOffset, options: .new) { [weak self] (tableView, value) in
            guard tableView.isDragging else { return } // прокручивает ли пользователь таблицу вручную
            print(">> dragging...")
            self?.reloadIfNeeded()
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reloadIfNeeded()
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        offsetObserver = nil
    }
}

extension LoadMoreCellController: ResourceLoadingView {
    public func display(_ viewModel: ResourceLoadingViewModel) {
        print(">> cell is loading? \(cell.isLoading)")
        cell.isLoading = viewModel.isLoading
    }
}

extension LoadMoreCellController: ResourceErrorView {
    public func display(_ viewModel: ResourceErrorViewModel) {
        cell.message = viewModel.message
    }
}
