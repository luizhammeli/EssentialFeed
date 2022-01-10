//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Luiz Diniz Hammerli on 09/01/22.
//

import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func compose(with feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedRefreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedViewController = FeedViewController(refreshController: feedRefreshController)
        
        feedRefreshController.onRefresh = adaptToCellControllers(forwardingTo: feedViewController, imageLoader: imageLoader)
        return feedViewController
    }
    
    private static func adaptToCellControllers(forwardingTo controller: FeedViewController, imageLoader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feedImage in
            controller?.tableModel = feedImage.map { FeedImageCellController(for: $0, imageLoader: imageLoader) }
        }
    }
}
