//
//  FeedViewPresenter.swift
//  EssentialFeediOS
//
//  Created by Luiz Diniz Hammerli on 16/01/22.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView {
    func onChange(isLoading: Bool)
}

protocol FeedView {
    func onFeedLoad(feedItem: [FeedImage])
}

public final class FeedViewPresenter {
    typealias Observer<T> = (T) -> Void
    private let feedLoader: FeedLoader

    public init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedLoadingView: FeedLoadingView?
    var feedView: FeedView?
    
    @objc func load() {
        feedLoadingView?.onChange(isLoading: true)
        feedLoader.load(completion: { [weak self] result in
            if let feedImage = try? result.get() {
                self?.feedView?.onFeedLoad(feedItem: feedImage)
            }
            self?.feedLoadingView?.onChange(isLoading: false)
        })
    }
}
