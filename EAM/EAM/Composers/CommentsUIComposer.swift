//
//  CommentsUIComposer.swift
//  EAM
//
//  Created by Denis Yaremenko on 21.03.2025.
//

import UIKit
import Combine
import EFMiOS
import EFM

public final class CommentsUIComposer {
    
    private init() {}
    
    private typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>
    
    public static func commentsComposedWith(commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>) -> ListViewController {
        
        let presentationAdapter = CommentsPresentationAdapter(loader: {
            commentsLoader()
        })
        
        let commentsController = makeCommentsViewController(title: ImageCommentsPresenter.title)
        commentsController.onRefresh = presentationAdapter.loadResource
        
        let commentsViewAdapter = CommentsViewAdapter(controller: commentsController)
        
        let resourcePresenter = LoadResourcePresenter.init(resourceView: commentsViewAdapter, loadingView: WeakRefVirtualProxy(commentsController), errorView: WeakRefVirtualProxy(commentsController), mapper: { ImageCommentsPresenter.map($0) })
        
        presentationAdapter.presenter = resourcePresenter
        
        return commentsController
    }

    private static func makeCommentsViewController(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        controller.title = title
        return controller
    }
}



