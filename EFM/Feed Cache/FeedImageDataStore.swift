//
//  FeedImageDataStore.swift
//  EFM
//
//  Created by Denis Yaremenko on 11.03.2025.
//

import Foundation

public protocol FeedImageDataStore {
    
    // async api
//    typealias RetrievalResult = Swift.Result<Data?, Error>
//    typealias InsertionResult = Swift.Result<Void, Error>
//    
//    @available(*, deprecated, message: "Use sync implementation instead")
//    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
//    
//    @available(*, deprecated, message: "Use sync implementation instead")
//    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void)

    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}

/*
public extension FeedImageDataStore {
    
    func insert(_ data: Data, for url: URL) throws {
        // возвращается Void (ничего), поэтому return try result.get() просто завершает выполнение или выбрасывает ошибку
        let group = DispatchGroup()
        
        group.enter()
        var result: InsertionResult!
        
        insert(data, for: url) {
            result = $0
            group.leave()
        }
        
        group.wait()
        return try result.get() // чтобы обработать возможную ошибку и завершить выполнение, так как метод ничего не возвращает
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        
        let group = DispatchGroup()
        
        group.enter()
        
        var result: RetrievalResult!
        
        retrieve(dataForURL: url) {
            result = $0
            group.leave()
        }
        
        group.wait()
        
        return try result.get()
    }
    
}
*/
