//
//  FeedCachePolicy.swift
//  EFM
//
//  Created by Denis Yaremenko on 10.03.2025.
//

import Foundation

final class FeedCachePolicy {
    
    private init() {}
    
    private static let calendar: Calendar = .init(identifier: .gregorian)
    private static var maxCacheAgeInDays: Int { 7 }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCachedAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCachedAge
    }
}
