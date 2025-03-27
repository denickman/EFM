//
//  FeedViewControllerTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Denis Yaremenko on 06.02.2025.
//

import Foundation
import EFM
import EFMiOS
import Combine

extension FeedUIIntegrationTests {
    
    class LoaderSpy: FeedImageDataLoader {
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            var fallback: () -> Void
            func cancel() {
                fallback()
            }
        }
        
        // MARK: - Properties
        
        var loadFeedCallCount: Int {
            feedRequests.count
        }
        
        var loadMoreCallCount: Int {
            loadMoreRequests.count
        }
        
        var loadedImageURLs: [URL] {
            imageRequests.map { $0.url }
        }
        
        
        private(set) var cancelledImageURLs = [URL]()
        
        private var feedRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
        private var loadMoreRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
        private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        // MARK: - FeedImageDataLoader
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any EFM.FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy(fallback: { [weak self] in
                self?.cancelledImageURLs.append(url)
            })
        }
        
        func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
            let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
            feedRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        // load feed
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            let paginated = Paginated(
                items: feed,
                loadMorePublisher: { [weak self] in
                    let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
                    self?.loadMoreRequests.append(publisher)
                    return publisher.eraseToAnyPublisher()
                })
            
            feedRequests[index].send(paginated)
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            feedRequests[index].send(completion: .failure(error))
        }
        
        // load image
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
        }
        
        // load more
        func completeLoadMore(
            with feed: [FeedImage] = [],
            lastPage: Bool = false,
            at index: Int = 0
        ) {
            let paginated = Paginated(
                items: feed,
                loadMorePublisher: lastPage ? nil : { [weak self] in
                    let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
                    self?.loadMoreRequests.append(publisher)
                    return publisher.eraseToAnyPublisher()
                })
            
            loadMoreRequests[index].send(paginated)
        }
        
        func completeLoadMoreWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            loadMoreRequests[index].send(completion: .failure(error))
        }
    }
}
