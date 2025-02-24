//
//  FeedImageCellViewModel.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 24.02.2025.
//

import Foundation


struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}
