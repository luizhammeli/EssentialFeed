//
//  FeedViewPresenter.swift
//  EssentialFeediOS
//
//  Created by Luiz Diniz Hammerli on 16/01/22.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView: AnyObject {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feedItem: [FeedImage])
}

public final class FeedViewPresenter {
    typealias Observer<T> = (T) -> Void
    private let feedLoader: FeedLoader
    var loadingView: FeedLoadingView?
    var feedView: FeedView?
    

    public init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    @objc func load() {
        loadingView?.display(isLoading: true)
        feedLoader.load(completion: { [weak self] result in
            if let feedImage = try? result.get() {
                self?.feedView?.display(feedItem: feedImage)
            }
            self?.loadingView?.display(isLoading: false)
        })
    }
}
