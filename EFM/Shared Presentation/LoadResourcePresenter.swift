//
//  LoadResourcePresenter.swift
//  EFM
//
//  Created by Denis Yaremenko on 17.03.2025.
//

import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    func display(_ viewModel: ResourceViewModel)
}

/// Роль: Преобразует данные в формат для UI (через mapper) и управляет состоянием загрузки/ошибок.
/// Бизнес-логика: Нет, только логика представления.
public final class LoadResourcePresenter<Resource, View: ResourceView> {
    
    public static var loadError: String {
        String(localized: "GENERIC_CONNECTION_ERROR")
    }
    
    // MARK: - Properties
    // Типы выводятся из resourceView и mapper, поэтому явное указание при init не нужно.
    public typealias Mapper = (Resource) throws -> View.ResourceViewModel
    
    private let resourceView: View
    private let loadingView: ResourceLoadingView
    private let errorView: ResourceErrorView
    private let mapper: Mapper
    
    // MARK: - Init
    
    public init(
        resourceView: View,
        loadingView: ResourceLoadingView,
        errorView: ResourceErrorView,
        mapper: @escaping Mapper
    ) {
        self.resourceView = resourceView
        self.loadingView = loadingView
        self.errorView = errorView
        self.mapper = mapper
    }
    
    // MARK: - Methods
    
    // Void -> creates view model -> sends to the UI
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(.init(isLoading: true))
    }
    
    // [FeedImage] -> creates view model -> sends to the UI
    // [ImageComment] -> creates view model -> sends to the UI
    // Resource -> ResourceViewModel -> sends to the UI
    public func didFinishLoading(with resource: Resource) {
        do {
            let model = try mapper(resource) // resource - Paginated<FeedImage>
            resourceView.display(model) // Paginated<FeedImage> - feed view adapter
            // resource - feedImage/ mapper - передаст в FeedViewAdapter уже готовую FeedViewModel
            // resource - data
            loadingView.display(.init(isLoading: false))
        } catch {
            didFinishLoading(with: error)
        }
    }
    
    // Error -> creates view model -> sends to the UI
    public func didFinishLoading(with error: Error) {
        errorView.display(.error(message: Self.loadError))
        loadingView.display(.init(isLoading: false))
    }

}
