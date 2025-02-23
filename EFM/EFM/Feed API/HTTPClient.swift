//
//  HTTPClient.swift
//  EFM
//
//  Created by Denis Yaremenko on 23.02.2025.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
