//
//  LoadResourcePresentationAdapter.swift
//  EAM
//
//  Created by Denis Yaremenko on 17.03.2025.
//

import Foundation
import EFMiOS
import EFM
import Combine

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    
    //MARK: - Properties
    
    var presenter: LoadResourcePresenter<Resource, View>? // resource - data, 
    private var cancellable: Cancellable?
    private let loader: () -> AnyPublisher<Resource, Error>
    
    // MARK: - Init
    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        presenter?.didStartLoading()
        
        cancellable = loader()
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case let .failure(error):
                    self?.presenter?.didFinishLoading(with: error)
                }
            } receiveValue: { [weak self] resource in // data or [feeditem]
                self?.presenter?.didFinishLoading(with: resource)
            }
    }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
        loadResource()
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
        cancellable = nil
    }
}
