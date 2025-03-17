//
//  ResourceErrorViewModel.swift
//  EFM
//
//  Created by Denis Yaremenko on 17.03.2025.
//

import Foundation

public struct ResourceErrorViewModel {
    
    public let message: String?
    
    static var noError: ResourceErrorViewModel {
        ResourceErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> ResourceErrorViewModel {
        ResourceErrorViewModel(message: message)
    }
}
