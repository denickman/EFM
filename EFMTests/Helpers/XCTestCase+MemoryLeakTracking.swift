//
//  XCTestCase+MemoryLeakTracking.swift
//  EFMTests
//
//  Created by Denis Yaremenko on 10.03.2025.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaking<T: AnyObject>(_ object: T, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "Instance should have been deallocated, potentially memory leak.", file: file, line: line)
        }
    }
}
