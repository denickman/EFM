//
//  FeedCachePolicy.swift
//  EFM
//
//  Created by Denis Yaremenko on 23.02.2025.
//

import Foundation

final class FeedCachePolicy {
    
    private init() {}
    
    private static let calendar: Calendar = .init(identifier: .gregorian)
    private static var maxCacheAgeInDays: Int { 7 }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
    
    
}
