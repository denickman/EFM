//
//  CombineHelpers.swift
//  EAM
//
//  Created by Denis Yaremenko on 15.03.2025.
//

import Foundation
import Combine
import EFM

public extension HTTPClient {
    typealias Publisher = AnyPublisher<(Data, HTTPURLResponse), Error>
    
    func getPublisher(url: URL) -> Publisher {
        var task: HTTPClientTask?
        
        return Deferred {
            Future { completion in
                task = self.get(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

public extension LocalFeedLoader {
    typealias Publisher = AnyPublisher<[FeedImage], Error>
    
    func loadPublisher() -> Publisher {
        Deferred {
            Future { completion in
                self.load(completion: completion)
            }
        }
        .eraseToAnyPublisher()
    }
}


//public extension FeedLoader {
//    typealias Publisher = AnyPublisher<[FeedImage], Error>
//    
//    func loadPublisher() -> Publisher {
//        Deferred {
//            Future { completion in
//                self.load(completion: completion)
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//}


public extension FeedImageDataLoader {
    
    typealias Publisher = AnyPublisher<Data, Error>
    
    func loadImageDataPublisher(from url: URL) -> Publisher {
        
        var task: FeedImageDataLoaderTask?
        
        return Deferred {
            Future { completion in
                task = self.loadImageData(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}

private extension FeedImageDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        save(data, url: url, completion: { _ in })
    }
}

extension Publisher where Output == Data {
    func caching(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data in
            // TODO: - Uncomment
              //  cache.saveIgnoringResult(data, for: url)
        })
        .eraseToAnyPublisher() // относится к Publisher а не к handleEvents
    }
}

extension Publisher where Output == [FeedImage] {
    /// Если основной Future завершился успешно, то handleEvents сработает и данные попадут в кеш.
    /// Если основной Future завершился с ошибкой, то handleEvents(receiveOutput:) не вызовется (так как нет успешного результата).
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { feed in
            // TODO: - Uncomment
           // cache.saveIgnoringResult(feed)
        })
        .eraseToAnyPublisher() 
    }
}


extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        // `self` is the primary
        // `fallbackPublisher` is the fallback
        // если future возращает failure - то здесь ошибку перехватит catch
        self.catch { _ in
            return fallbackPublisher()
        }.eraseToAnyPublisher()
    }
}

// MARK: - Main Queue Processing

extension Publisher {
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler)
            .eraseToAnyPublisher()
    }
}

// MARK: - Custom DispatchQueue to handle main queue processing

extension DispatchQueue {
    static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
        ImmediateWhenOnMainQueueScheduler.shared
    }
    
    struct ImmediateWhenOnMainQueueScheduler: Scheduler {
        
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        
        // MARK: - Public
        
        var now: SchedulerTimeType {
            DispatchQueue.main.now
        }
        
        var minimumTolerance: SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }
        
        static let shared = Self()
        
        // MARK: - Private
        private static let key = DispatchSpecificKey<UInt8>()
        private static let value = UInt8.max
        
        // MARK: - Init
        private init() {
            DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
        }
        
        // MARK: - Scheduler
        func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
            guard isMainQueue() else {
                return DispatchQueue.main.schedule(options: options, action)
            }
            
            // the main queue is guaranteed to be running on the main thread
            // the main thread is not guaranteed to be running the main queue
            
            action()
        }
        
        func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }
        
        func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
       
        private func isMainQueue() -> Bool {
             DispatchQueue.getSpecific(key: Self.key) == Self.value
        }
    }
}
