//
//  FeedErrorViewModel.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 24.02.2025.
//

import Foundation

public struct FeedErrorViewModel {
    
    public let message: String?
    
    static var noError: FeedErrorViewModel {
        .init(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        .init(message: message)
    }
}
