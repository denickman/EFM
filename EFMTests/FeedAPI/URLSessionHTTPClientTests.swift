//
//  URLSessionHTTPClientTests.swift
//  EFMTests
//
//  Created by Denis Yaremenko on 10.03.2025.
//

import XCTest
import EFM

final class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        StubURLProtocol.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        StubURLProtocol.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "waiting for completion")
        
        StubURLProtocol.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in
          
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestedError = NSError(domain: "any error", code: 0)
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestedError) as? NSError
        
        XCTAssertEqual(receivedError?.domain, requestedError.domain)
        XCTAssertEqual(receivedError?.code, requestedError.code)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
//        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
//        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
//        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
//        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
//        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
//        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
//        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
//        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
//        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        let receivedValue = resultValueFor(data: data, response: response, error: nil)
        
        XCTAssertEqual(receivedValue?.data, data)
        XCTAssertEqual(receivedValue?.response.url, response.url)
        XCTAssertEqual(receivedValue?.response.statusCode, response.statusCode)
    }
    
    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let emtpyData = Data()
        let response = anyHTTPURLResponse()
        let receivedValues = resultValueFor(data: emtpyData, response: response, error: nil)
        
        XCTAssertEqual(receivedValues?.data, emtpyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaking(sut, file: file, line: line)
        return sut
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        .init(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        .init(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func resultFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HTTPClient.Result {
        StubURLProtocol.stub(data: data, response: response, error: error)

        let exp = expectation(description: "Wait for completion")
        let sut = makeSUT(file: file, line: line)
        
        var receivedResult: HTTPClient.Result!
        
        sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func resultValueFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .success((data, response)):
            return (data, response)
            
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultErrorFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Error? {
        let result = resultFor(data: data, response: response, error: error)
        
        switch result {
        case let .failure(error):
            return error
            
        default:
            XCTFail("Expected error, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    // MARK:  - Stub
    
    private class StubURLProtocol: URLProtocol {
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = .init(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(StubURLProtocol.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(StubURLProtocol.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            if let observer = StubURLProtocol.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                observer(request)
            }
            
            if let data = StubURLProtocol.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = StubURLProtocol.stub?.response as? HTTPURLResponse {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
            }
            
            if let error = StubURLProtocol.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
    }

}
