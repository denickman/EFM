//
//  UIRefreshControl+Ext.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 24.02.2025.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
