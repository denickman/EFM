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

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    
    public static var loadError: String {
        String(localized: "GENERIC_CONNECTION_ERROR")
    }
    
    // MARK: - Properties
    
    public typealias Mapper = (Resource) -> View.ResourceViewModel
    
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
        resourceView.display(mapper(resource))
        loadingView.display(.init(isLoading: false))
    }
    
    // Error -> creates view model -> sends to the UI
    public func didFinishLoading(with error: Error) {
        errorView.display(.error(message: Self.loadError))
        loadingView.display(.init(isLoading: false))
    }

}
