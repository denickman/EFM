//
//  HTTPClientProfilingDecorator.swift
//  EAM
//
//  Created by Denis Yaremenko on 30.03.2025.
//

import UIKit
import Combine
import EFM
import os

class HTTPClientProfilingDecorator: HTTPClient {

    private let decoratee: HTTPClient
    private let logger: Logger
    
    init(decoratee: HTTPClient, logger: Logger) {
        self.decoratee = decoratee
        self.logger = logger
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> EFM.HTTPClientTask {
        logger.traceThis("Started loading url: \(url)")
        
        let startTime = CACurrentMediaTime()
        
        return decoratee.get(from: url, completion: { [logger] result in
            
            if case let .failure(error) = result {
                logger.traceThis("FAILED to load url: \(url) with error: \(error)")
            }
            
            let elapsed = CACurrentMediaTime() - startTime
            logger.traceThis("Finished loading url in \(elapsed) seconds.")
        })
    }
}

private extension Logger {
    func traceThis(_ message: String) {
        return self.trace("LOGGER: \(message)")
    }
}

// Or using a Combine approach

extension Publisher {
    func logErrors(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveCompletion: { result in
            if case let .failure(error) = result {
                logger.traceThis("Failed to load url: \(url) with error: \(error)")
            }
        }).eraseToAnyPublisher()
    }
    
    func logElapsedTime(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        var startTime = CACurrentMediaTime()

        return handleEvents(receiveSubscription: { _ in
            logger.traceThis("Started loading url: \(url)")
            startTime = CACurrentMediaTime()
        }, receiveCompletion: { _ in
            let elapsed = CACurrentMediaTime() - startTime
            logger.trace(">> Finished loading url in \(elapsed) seconds.")
        }).eraseToAnyPublisher()
        
    }
}
