//
//  LoadFeedFromRemoteUseCaseTests.swift
//  EFMTests
//
//  Created by Denis Yaremenko on 10.03.2025.
//

import XCTest
import EFM

final class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertEqual(client.urls, [])
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://example.com/feed.xml")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.urls, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://example.com/feed.xml")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.urls, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let errorResult = RemoteFeedLoader.Error.connectivity
        
        expect(sut, toCompleteWith: .failure(errorResult)) {
            client.completeWith(error: anyNSError())
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199] // , 201, 300, 400, 500]
        let error = RemoteFeedLoader.Error.invalidData
        let json = makeData(from: [])
        
        expect(sut, toCompleteWith: .failure(error)) {
            samples.enumerated().forEach { index, code in
                client.completeWith(statusCode: code, data: json)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidData() {
        let (sut, client) = makeSUT()
        let error = RemoteFeedLoader.Error.invalidData
        let invalidData = Data("invalid_json".utf8)
        
        expect(sut, toCompleteWith: .failure(error)) {
            client.completeWith(statusCode: 200, data: invalidData)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        let emptyData = makeData(from: [])
        
        expect(sut, toCompleteWith: .success([])) {
            client.completeWith(statusCode: 200, data: emptyData)
        }
    }
    
    func test_load_devliersItemsOn200HTTPResponseWithValidData() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "https://someurl.com")!
        )
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "https://someanotherurl.com")!
        )
        
        let data = makeData(from: [item1.json, item2.json])
        
        expect(sut, toCompleteWith: .success([item1.item, item2.item])) {
            client.completeWith(statusCode: 200, data: data)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
        let url = URL(string: "https://example.com/feed.xml")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var expectedResult: FeedLoader.Result?
        
        sut?.load { result in
            expectedResult = result
        }
        
        sut = nil
        
        client.completeWith(error: URLError(.badServerResponse))
        
        XCTAssertNil(expectedResult, "Expected nil, got \(String(describing: expectedResult)) instead")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        url: URL = URL(string: "https://example.com/feed.xml")!,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaking(client, file: file, line: line)
        trackForMemoryLeaking(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWith expectedResult: FeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for completion")
        
        sut.load { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(expectedFeed), .success(receivedFeed)):
                XCTAssertEqual(expectedFeed, receivedFeed, file: file, line: line)
                
            case let (.failure(expectedError as RemoteFeedLoader.Error), .failure(receivedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeItem(
        id: UUID,
        description: String? = nil,
        location: String? = nil,
        imageURL: URL
    ) -> (item: FeedImage, json: [String : Any]) {
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        let json = [
            "id" : id.uuidString,
            "description" : description,
            "location" : location,
            "image" : imageURL.absoluteString
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeData(from json: [[String : Any]]) -> Data {
        let json = ["items" : json]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    // MARK: - Spy
    
    private class HTTPClientSpy: HTTPClient {
        
        var urls: [URL] { messages.map { $0.url } }
        
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url: url, completion: completion))
        }
        
        func completeWith(statusCode: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: urls[index], statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
        
        func completeWith(error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
}
