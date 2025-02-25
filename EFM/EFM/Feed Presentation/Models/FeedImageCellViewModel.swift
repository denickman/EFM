//
//  FeedImageCellViewModel.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 24.02.2025.
//

import Foundation

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        location != nil
    }
}
