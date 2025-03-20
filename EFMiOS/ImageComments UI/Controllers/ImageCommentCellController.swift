//
//  ImageCommentCellController.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 19.03.2025.
//

import UIKit
import EFM

// if you are implementing UIKit protocols you have to inherit your class from NSObject

public final class ImageCommentCellController: NSObject, UITableViewDataSource {
    
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    // MARK: - UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.messageLabel.text = model.message
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.date
        return cell
    }
}
