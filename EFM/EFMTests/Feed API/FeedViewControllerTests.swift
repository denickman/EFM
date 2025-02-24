//
//  FeedViewControllerTests.swift
//  EFMiOSTests
//
//  Created by Denis Yaremenko on 24.02.2025.
//

import XCTest
import EFM

class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://example.com/feed.xml")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://example.com/feed.xml")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(
            sut,
            toCompleteWith: failure(.connectivity),
            when: {
                let error = NSError(domain: "Test", code: 0)
                client.complete(withError: error)
            })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(
                sut,
                toCompleteWith: failure(.invalidData),
                when: {
                    let json = makeItemsJson([])
                    client.complete(withCode: code, data: json, at: index)
                })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData)) {
            let jsonData = Data("Invalid JSON".utf8)
            client.complete(withCode: 200, data: jsonData)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emtpyJson = makeItemsJson([])
            client.complete(withCode: 200, data: emtpyJson)
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
        
        let items = makeItemsJson([item1.json, item2.json])
        
        expect(sut, toCompleteWith: .success([item1.item, item2.item])) {
            client.complete(withCode: 200, data: items)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
        let url = URL(string: "https://example.com/feed.xml")!
        
        let client = HTTPClientSpy()
        
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var expectedResult: FeedLoader.Result?
        
        sut?.load(completion: { result in
            expectedResult = result
        })
        
        sut = nil
        
        client.complete(withError: NSError(domain: "", code: 0))
        
        XCTAssertNil(expectedResult)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        url: URL = URL(string: "https://example.com/feed.xml")!,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWith expectedResult: RemoteFeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(expectedFeed), .success(receivedFeed)):
                XCTAssertEqual(expectedFeed, receivedFeed, file: file, line: line)
                
            case let (.failure(expectedError as RemoteFeedLoader.Error), .failure(receivedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(expectedError, receivedError)
                
            default:
                XCTFail("Expect result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
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
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues({$0})
        
        return (item, json)
    }
    
    private func makeItemsJson(_ items: [[String : Any]]) -> Data {
        let json = ["items" : items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> FeedLoader.Result {
        .failure(error)
    }
    
    // MARK: - HTTPClient
    
    private class HTTPClientSpy: HTTPClient {
        
        var requestedURLs: [URL] {
            messages.map {
                $0.url
            }
        }
        
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url: url, completion: completion))
        }
        
        func complete(withError error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withCode statusCode: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
        
    }
}
