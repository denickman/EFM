//
//  MemoryLeakHelper.swift
//  EFMTests
//
//  Created by Denis Yaremenko on 24.02.2025.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks<T: AnyObject>(_ object: T, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "Instance should have been deallocated, potentially memory leak.", file: file, line: line)
        }
    }
}
