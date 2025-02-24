//
//  UITableView+Ext.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 24.02.2025.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let id = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: id) as! T
    }
}
