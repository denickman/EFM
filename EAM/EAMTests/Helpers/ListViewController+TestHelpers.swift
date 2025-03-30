//
//  ListViewController+TestHelpers.swift
//  EAMTests
//
//  Created by Denis Yaremenko on 27.03.2025.
//

import UIKit
import EFM
import EFMiOS

extension ListViewController {
    
    // MARK: - Properties
    
    var feedImagesSection: Int { 0 }
    var feedLoadMoreSection: Int { 1 }
    
    var errorMessage: String? {
        errorView.message
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    var isShowingLoadMoreFeedIndicator: Bool {
        loadMoreFeedCell()?.isLoading == true
    }
    
    var loadMoreFeedErrorMessage: String? {
        loadMoreFeedCell()?.message
    }
    
    var canLoadMoreFeed: Bool {
        loadMoreFeedCell() != nil
    }
    
    // MARK: - Methods
    
    func simulateTapOnFeedImage(at row: Int) {
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }
    
    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    func simulateLoadMoreFeedAction() {
        guard let view = loadMoreFeedCell() else { return }
        
        let delegate = tableView.delegate
        let index = IndexPath(row: 0, section: feedLoadMoreSection)
        delegate?.tableView?(tableView, willDisplay: view, forRowAt: index)
    }
    
    func simulateTapOnLoadMoreFeedError() {
        let delegate = tableView.delegate
        let index = IndexPath(row: 0, section: feedLoadMoreSection)
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        /// tableView.reloadData does not force an immediate layout update
        /// 'didEndDisplayingCell' will only be called in the next layout cycle
        ///
        /// reloadData() сообщает таблице: "Обнови данные, когда будет следующий цикл обработки". Но если вы запрашиваете numberOfRows(inSection:) до того, как этот цикл завершится, таблица еще не "знает" о новых данных.
        /// Источник данных (dataSource) уже может содержать обновленные данные (например, массив с новыми изображениями), но сама таблица еще не применила их к своему внутреннему состоянию.
        ///
        /// Пример баги:
        
//        Допустим, у вас было 5 ячеек в секции.
//        Вы добавили еще 5 элементов в массив данных и вызвали reloadData().
//        Сразу вызвали numberOfRenderedFeedImageViews().
//        Вместо ожидаемых 10 ячеек функция может вернуть 5, потому что таблица еще не обновилась.
        
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        return view
    }
    
    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }
    
    private func loadMoreFeedCell() -> LoadMoreCell? {
        cell(row: 0, section: feedLoadMoreSection) as? LoadMoreCell
    }
    
    func cell(row: Int, section: Int) -> UITableViewCell? {
        guard numberOfRows(in: section) > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    // Simulate and Rendering
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }

    func renderedFeedImageData(at index: Int) -> Data? {
        simulateFeedImageViewVisible(at: index)?.renderedImage
    }
    
    func simulateErrorViewTap() {
        errorView.simulateTap()
    }
}


extension ListViewController {
    private var commentsSection: Int {
        .zero
    }
    
    func numberOfRenderedComments() -> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: commentsSection)
    }
    
    func commentMessage(at row: Int) -> String? {
        commentView(at: row)?.messageLabel?.text
    }
    
    func commentDate(at row: Int) -> String? {
        commentView(at: row)?.dateLabel?.text
    }
    
    func commentUsername(at row: Int) -> String? {
        commentView(at: row)?.usernameLabel?.text
    }
    
    func commentView(at row: Int) -> ImageCommentCell? {
        guard numberOfRenderedComments() > row else { return nil }
        
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: commentsSection)
        return ds?.tableView(tableView, cellForRowAt: index) as? ImageCommentCell
    }
    
}













