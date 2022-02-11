//
//  FeedViewPresenter.swift
//  EssentialFeediOS
//
//  Created by Luiz Diniz Hammerli on 16/01/22.
//

import Foundation
import EssentialFeed

public struct FeedLoadingViewModel {
    let isLoading: Bool
}

public struct FeedViewModel {
    let feedItem: [FeedImage]
}

public protocol FeedLoadingView: AnyObject {
    func display(viewModel: FeedLoadingViewModel)
}

public protocol FeedView {
    func display(viewModel: FeedViewModel)
}

public final class FeedViewPresenter {
    var loadingView: FeedLoadingView
    var feedView: FeedView
    
    static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedViewPresenter.self), comment: "")
    }
    
    public init(loadingView: FeedLoadingView, feedView: FeedView) {
        self.loadingView = loadingView
        self.feedView = feedView
    }
    
    func didFinishLoadingFeed(feedItem: [FeedImage]) {
        loadingView.display(viewModel: .init(isLoading: false))
        feedView.display(viewModel: .init(feedItem: feedItem))
    }
    
    func didStartLoadingFeed() {
        loadingView.display(viewModel: .init(isLoading: true))
    }
    
    func didLoadFeedWithError() {
        loadingView.display(viewModel: .init(isLoading: false))
    }
}
