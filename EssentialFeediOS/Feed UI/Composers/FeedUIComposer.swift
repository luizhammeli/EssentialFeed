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
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let feedRefreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedViewController = FeedViewController(refreshController: feedRefreshController)
        
        feedViewModel.onFeedLoad = adaptToCellControllers(forwardingTo: feedViewController, imageLoader: imageLoader)
        return feedViewController
    }
    
    private static func adaptToCellControllers(forwardingTo controller: FeedViewController, imageLoader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feedImage in
            controller?.tableModel = feedImage.map { FeedImageCellController(viewModel: FeedImageCellViewModel(model: $0,
                                                                                                               imageLoader: imageLoader,
                                                                                                               imageTransformer: UIImage.init)) }
        }
    }
}
