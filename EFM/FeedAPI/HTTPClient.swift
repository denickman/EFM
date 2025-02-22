//
//  HTTPClient.swift
//  EFM
//
//  Created by Denis Yaremenko on 22.02.2025.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func get(from url: URL, compleiton: @escaping (Result) -> Void)
}
