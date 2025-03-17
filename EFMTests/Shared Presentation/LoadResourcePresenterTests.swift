//
//  LoadResourcePresenterTests.swift
//  EFMTests
//
//  Created by Denis Yaremenko on 17.03.2025.
//

import EFM
import Foundation
import Testing

struct LoadResourcePresenterTests {

    @Test
    func initDoesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        #expect(view.messages.isEmpty, "Expected no view messages")
    }
    
    @Test
    func didStartLoadingDisplaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()
        sut.didStartLoading()
        #expect(view.messages == [.display(errorMessage: .none), .display(isLoading: true)])
    }
    
    @Test
    func didFinishLoadingResource_displaysResourceAndStopsLoading() {
        let (sut, view) = makeSUT(mapper: { resource in
            resource + " view model"
        })
                                  
        sut.didFinishLoading(with: "resource")
        
        #expect(view.messages == [.display(resource: "resource view model"), .display(isLoading: false)])
    }
    
    @Test
    func didFinishLoadingWithErrorDisplaysLocalizedErrorMessageAndStopsLoading() {
        let (sut, view) = makeSUT()
        sut.didFinishLoading(with: anyNSError())
        
        #expect(view.messages == [.display(errorMessage: .some(localized("GENERIC_CONNECTION_ERROR"))), .display(isLoading: false)])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LoadResourcePresenter<String, ViewSpy>
    
    private func makeSUT(
        mapper: @escaping SUT.Mapper = { _ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: SUT, view: ViewSpy) {
        let view = ViewSpy()
        let sut = SUT(resourceView: view, loadingView: view, errorView: view, mapper: mapper)
        return (sut, view)
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let value = String(localized: .init(key))
        #expect(value == key, "Missing localized string for key: \(key)")
        return value
    }
    
    private class ViewSpy: ResourceView, ResourceLoadingView, ResourceErrorView {
        
        typealias ResourceViewModel = String
        
        enum Message: Hashable {
            case display(resource: String)
            case display(isLoading: Bool)
            case display(errorMessage: String?)
        }
        
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: ResourceLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: String) {
            messages.insert(.display(resource: viewModel))
        }
        
        func display(_ viewModel: ResourceErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
    }
}

