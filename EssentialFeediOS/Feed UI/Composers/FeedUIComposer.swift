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
        
        feedViewPresenter.loadingView = WeakRefVirtualProxy(instance: feedRefreshController)
        feedViewPresenter.feedView = FeedViewAdapter(controller: feedViewController, imageLoader: imageLoader)
        return feedViewController
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var instance: T?
    init(instance: T) {
        self.instance = instance
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(isLoading: Bool) {
        instance?.display(isLoading: isLoading)
    }
}

final class FeedViewAdapter {
    private weak var controller: FeedViewController?
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

extension FeedViewAdapter: FeedView {
    func display(feedItem: [FeedImage]) {
        adaptToCellControllers(feedImage: feedItem)
    }
}
