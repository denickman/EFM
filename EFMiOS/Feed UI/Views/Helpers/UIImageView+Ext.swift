//
//  UIImageView+Ext.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 11.03.2025.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        
        if newImage != nil {
            alpha = .zero
            UIView.animate(withDuration: 0.25) {
                self.alpha = 1
            }
        }
    }
}
