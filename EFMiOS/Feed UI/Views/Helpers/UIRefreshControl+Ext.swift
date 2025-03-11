//
//  UIRefreshControl+Ext.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 11.03.2025.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
