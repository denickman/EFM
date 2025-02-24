//
//  SharedHelpers.swift
//  EFMTests
//
//  Created by Denis Yaremenko on 24.02.2025.
//

import Foundation

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    Data("any_data".utf8)
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 1)
}
