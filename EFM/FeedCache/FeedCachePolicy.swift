//
//  FeedCachePolicy.swift
//  EFM
//
//  Created by Denis Yaremenko on 22.02.2025.
//

import Foundation

final class FeedCachePolicy {
    
    private init() {}
    
    private static let calendar: Calendar = .init(identifier: .gregorian)
    private static var maxAgeCacheInDays: Int { 7 }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxAgeCacheInDays, to: date) else {
            return false
        }
        return date < maxCacheAge
    }
}
