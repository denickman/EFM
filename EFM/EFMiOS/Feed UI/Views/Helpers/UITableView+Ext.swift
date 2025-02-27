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
    
    /// используется для динамической подгонки высоты tableHeaderView (представления, размещенного в верхней части таблицы) в зависимости от его контента.
    ///
    /// вычисляет желаемый размер для заголовка, используя метод systemLayoutSizeFitting(_:). Этот метод возвращает минимальные размеры для представления, которые могут вместить все его содержимое, принимая во внимание ограничения (например, высоту, заданную для элементов внутри заголовка). В данном случае используется UIView.layoutFittingCompressedSize, что означает, что система попытается минимизировать высоту заголовка, не увеличивая его ширину.
    ///
    /// вычисляет желаемый размер для заголовка, используя метод systemLayoutSizeFitting(_:). Этот метод возвращает минимальные размеры для представления, которые могут вместить все его содержимое, принимая во внимание ограничения (например, высоту, заданную для элементов внутри заголовка). В данном случае используется UIView.layoutFittingCompressedSize, что означает, что система попытается минимизировать высоту заголовка, не увеличивая его ширину.
    ///
    /// Когда содержимое заголовка таблицы изменяется (например, текст в UILabel, который используется внутри tableHeaderView, становится длиннее или короче), важно, чтобы высота заголовка адаптировалась под новый контент, чтобы предотвратить обрезание или пустое пространство.
    
    /// Этот метод полезен в следующих ситуациях:

    /// Когда контент заголовка таблицы изменяется динамически, и нужно обновить его высоту.
    /// Если заголовок имеет сложную иерархию элементов и требуется автоматическая подгонка высоты под содержимое.

    func sizeTableHeaderToFit() {
        guard let header = tableHeaderView else { return }
        let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let needsFrameUpdate = header.frame.height != size.height
        
        if needsFrameUpdate {
            header.frame.size.height = size.height
            tableHeaderView = header
        }
    }
}
