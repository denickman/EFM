//
//  RemoteFeedItem.swift
//  EFM
//
//  Created by Denis Yaremenko on 22.02.2025.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let url: URL 
}

