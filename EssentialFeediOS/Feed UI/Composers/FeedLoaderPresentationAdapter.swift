//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Luiz Hammerli on 29/01/22.
//

import Foundation
import EssentialFeed

public final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    let feedLoader: FeedLoader
    var feedPresenter: FeedViewPresenter?
    
    public init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    public func didRequestLoadFeed() {
        feedPresenter?.didStartLoadingFeed()
        
        feedLoader.load(completion: { [weak self] result in
            if let feedImage = try? result.get() {
                self?.feedPresenter?.didFinishLoadingFeed(feedItem: feedImage)
            }
            self?.feedPresenter?.didLoadFeedWithError()
        })
    }
}
