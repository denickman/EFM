//
//  UIImage+TestHelpers.swift
//  EFMiOSTests
//
//  Created by Denis Yaremenko on 27.02.2025.
//

import UIKit

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1 // устанавливаем коэффициент масштаба изображения (scale) равным 1, что значит, что изображение будет создано с обычной плотностью пикселей (1x). Это важно для того, чтобы изображение было не увеличено или уменьшено.
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}

