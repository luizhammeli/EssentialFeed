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
    
    public static func feedCompose(with feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        let feedRefreshController = FeedRefreshViewController(delegate: presentationAdapter)
        
        let feedViewController = FeedViewController.makeWith(refreshController: feedRefreshController,
                                                             title: FeedViewPresenter.title)
        
        let feedViewPresenter = FeedViewPresenter(loadingView: WeakRefVirtualProxy(instance: feedRefreshController),
                                                  feedView: FeedViewAdapter(controller: feedViewController,
                                                                            imageLoader: imageLoader))
        presentationAdapter.feedPresenter = feedViewPresenter
        return feedViewController
    }
}

extension FeedViewController {
    public static func makeWith(refreshController: FeedRefreshViewController, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateViewController(withIdentifier: "FeedViewController") as! FeedViewController
        feedViewController.feedRefreshController = refreshController
        feedViewController.title = title
        
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
    func display(viewModel: FeedLoadingViewModel) {
        instance?.display(viewModel: viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    typealias Image = UIImage
    
    func display(model: FeedCellViewModel<UIImage>) {
        instance?.display(model: model)
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
        controller?.tableModel = feedImage.map {
            let adapter = FeedImageCellPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: $0, imageLoader: imageLoader)
            let controller = FeedImageCellController(delegate: adapter)
            adapter.presenter = FeedImageCellPresenter(view: WeakRefVirtualProxy(instance: controller), imageTransformer: UIImage.init)
            return controller
        }
    }
}

extension FeedViewAdapter: FeedView {
    func display(viewModel: FeedViewModel) {
        adaptToCellControllers(feedImage: viewModel.feedItem)
    }
}
