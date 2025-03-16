//
//  ImageComments.swift
//  EFM
//
//  Created by Denis Yaremenko on 16.03.2025.
//

import Foundation

public struct ImageComment: Equatable {
    
    public let id: UUID
    public let message: String
    public let username: String
    public let createdAt: Date
    
    public init(id: UUID, message: String, username: String, createdAt: Date) {
        self.id = id
        self.message = message
        self.username = username
        self.createdAt = createdAt
    }
}
