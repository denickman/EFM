//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EFM
//
//  Created by Denis Yaremenko on 25.02.2025.
//

import XCTest
import EFM

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    
    func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
    }

    func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        deleteCache(from: sut)
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
}
