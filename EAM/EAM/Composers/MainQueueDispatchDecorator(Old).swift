//
//  MainQueueDispatchDecorator.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 11.03.2025.
//
/*
import Foundation
import EFM

final class MainQueueDispatchDecorator<T> {
    
    private let decoratee: T
    
    init(_ decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                completion()
            }
            return
        }
        completion()
    }
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
    
}

*/
