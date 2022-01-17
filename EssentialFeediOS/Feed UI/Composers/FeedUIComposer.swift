//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Luiz Diniz Hammerli on 09/01/22.
//

import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init() {}
    
    public static func compose(with feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewPresenter = FeedViewPresenter(feedLoader: feedLoader)
        let feedRefreshController = FeedRefreshViewController(presenter: feedViewPresenter)
        let feedViewController = FeedViewController(refreshController: feedRefreshController)
        
        feedViewPresenter.feedLoadingView = feedRefreshController
        feedViewPresenter.feedView = FeedoCellControllerAdapter(controller: feedViewController, imageLoader: imageLoader)
        return feedViewController
    }
}

final class FeedoCellControllerAdapter {
    private let controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func adaptToCellControllers(feedImage: [FeedImage]) {
        controller?.tableModel = feedImage.map { FeedImageCellController(viewModel: FeedImageCellViewModel(model: $0,
                                                                                                           imageLoader: imageLoader,
                                                                                                           imageTransformer: UIImage.init)) }
    }
}

extension FeedoCellControllerAdapter: FeedView {
    func onFeedLoad(feedItem: [FeedImage]) {
        adaptToCellControllers(feedImage: feedItem)
    }
}
