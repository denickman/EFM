//
//  SharedTestHelpers.swift
//  EFMTests
//
//  Created by Denis Yaremenko on 10.03.2025.
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

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let json = [ "items" : items ]
    return try! JSONSerialization.data(withJSONObject: json)
}
