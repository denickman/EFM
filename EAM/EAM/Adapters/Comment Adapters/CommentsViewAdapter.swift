//
//  CommentsViewAdapter.swift
//  EAM
//
//  Created by Denis Yaremenko on 21.03.2025.
//

import Foundation
import EFM
import EFMiOS

final class CommentsViewAdapter: ResourceView {
    
    private weak var controller: ListViewController?
    
    init(controller: ListViewController) {
        self.controller = controller
    }
    
    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map { viewModel in
            CellController(id: viewModel, ImageCommentCellController(model: viewModel))
        })
    }
}


