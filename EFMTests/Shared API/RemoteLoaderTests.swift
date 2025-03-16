//
//  RemoteLoaderTests.swift
//  EFMTests
//
//  Created by Denis Yaremenko on 16.03.2025.
//

import Testing
import EFM
import Foundation

///#expect автоматически регистрирует провал, если условие ложно, и завершает тест (или помечает его как неудачный).
///Issue.record даёт вам контроль: вы можете зарегистрировать проблему и продолжить выполнение, если нужно проверить что-то ещё.
///
/// Issue.record — это метод в Swift Testing, который используется для явной регистрации проблемы (ошибки) в тесте. Это аналог XCTFail из XCTest, но с более гибким подходом, так как он интегрируется в систему "issues" нового фреймворка.
/// В отличие от #expect, который автоматически завершает тест при провале, Issue.record позволяет продолжить выполнение теста после регистрации проблемы, если это нужно.
/// Используйте Issue.record, если логика теста не покрывается простым #expect, или если вы хотите явно указать причину провала.
/// Например, когда результат не соответствует ни одному из ожидаемых случаев в switch.

struct RemoteLoaderTests {
    
    @Test
    func initDoesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        #expect(client.requestedURLs.isEmpty)
    }
    
    @Test
    func loadRequestsDataFromURL() {
        let url = URL(string: "https://example.com/feed.xml")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        #expect(client.requestedURLs == [url])
    }
    
    @Test
    func loadTwiceRequestsDataFromURLTwice() {
        let url = URL(string: "https://example.com/feed.xml")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        #expect(client.requestedURLs == [url, url])
    }
    
    @Test
    func loadDeliversErrorOnClientError() async {
        let (sut, client) = makeSUT()
        
        await #expect(throws: RemoteLoader<String>.Error.connectivity) {
            try await withCheckedThrowingContinuation { continuation in
                sut.load { result in
                    continuation.resume(with: result)
                }
                let clientError = anyNSError()
                client.complete(with: clientError)
            }
        }
    }
    
    @Test
    func loadDeliversErrorOnMapperError() async throws {
        let (sut, client) = makeSUT(mapper: {_,_ in
            throw anyNSError()
        })
        
        await #expect(throws: RemoteLoader<String>.Error.invalidData) {
            try await withCheckedThrowingContinuation { continuation in
                sut.load { result in
                    continuation.resume(with: result)
                }
                client.complete(with: 200, data: anyData())
            }
        }
    }
    
    @Test
    func loadDevliersMappedResource() {
        let resource = "a resource"
        
        let (sut, client) = makeSUT(mapper: { data, _ in
            String(data: data, encoding: .utf8)!
        })
        
        sut.load { result in
            if let receivedResource = try? result.get() {
                #expect(receivedResource == resource)
            }
        }
        
        client.complete(with: 200, data: Data(resource.utf8))
    }
    
    @Test
    func loadDoesNotDeliverResultAfterSUTHasBeenDeallocated() {
        let url = URL(string: "https://someanotherurl.com")!
        
        let client = HTTPClientSpy()
        var sut: RemoteLoader<String>? = RemoteLoader<String>(url: url, client: client, mapper: { _,_ in
            "any"
        })
        
        var capturedResults = [RemoteLoader<String>.Result]()
        
        sut?.load { result in
            capturedResults.append(result)
        }
        
        sut = nil
        client.complete(with: 200, data: Data())
        
        #expect(capturedResults.isEmpty)
    }
    
    
    // MARK: - Private
    
    private func makeSUT(
        url: URL = URL(string: "https://example.com/feed.xml")!,
        mapper: @escaping RemoteLoader<String>.Mapper = { _,_ in "foo" }
    ) -> (sut: RemoteLoader<String>, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteLoader<String>(url: url, client: client, mapper: mapper)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
        .failure(error)
    }
    
}
