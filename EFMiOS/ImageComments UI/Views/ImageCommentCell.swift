//
//  ImageCommentCell.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 19.03.2025.
//

import UIKit

public final class ImageCommentCell: UITableViewCell {
    @IBOutlet private(set) public var messageLabel: UILabel!
    @IBOutlet private(set) public var usernameLabel: UILabel!
    @IBOutlet private(set) public var dateLabel: UILabel!
}

//hugging priority
//Высокий → меньше растяжения (компактнее).
//Низкий → больше растяжения (растягивается сильнее).
//
//compresison resistance
//Высокий приоритет → меньше сжатия.
//Низкий приоритет → больше сжатия.
