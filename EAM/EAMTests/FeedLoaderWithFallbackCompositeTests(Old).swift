//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EAMTests
//
//  Created by Denis Yaremenko on 13.03.2025.
//

/*
import XCTest
import EFM
import EAM

/// this `FeedLoaderWithFallbackCompositeTests` will not suppose to be used anymore in future in favor of `FeedAcceptaceTests`,
/// since we add `FeedAcceptaceTests` which allows us to test business logic more precisely

final class FeedLoaderWithFallbackCompositeTests: XCTestCase, FeedLoaderTestCase {
    
    // no fail
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        expect(sut, toCompleteWith: .success(primaryFeed))
    }
    
    // primary fail
    func test_load_deliversFallbackFeedOnPrimaryFailure() {
        let fallbackFeed = uniqueFeed()
        
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))
        expect(sut, toCompleteWith: .success(fallbackFeed))
    }
    
    // both fail
    func test_load_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() {
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        primaryResult: FeedLoader.Result,
        fallbackResult: FeedLoader.Result,
        file: StaticString = #file,
        line: UInt = #line
    ) -> FeedLoader {
        let primaryLoader = FeedLoaderStub(result: primaryResult)
        let fallbackLoader = FeedLoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        
        return sut
    }
}
*/
