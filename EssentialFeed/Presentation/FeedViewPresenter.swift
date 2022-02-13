//
//  FeedViewPresenter.swift
//  EssentialFeed
//
//  Created by Luiz Hammerli on 13/02/22.
//

import Foundation

public struct FeedLoadingViewModel {
    public let isLoading: Bool
}

public struct FeedViewModel {
    public let feedItem: [FeedImage]
}

public protocol FeedLoadingView: AnyObject {
    func display(viewModel: FeedLoadingViewModel)
}

public protocol FeedView {
    func display(viewModel: FeedViewModel)
}

public final class FeedViewPresenter {
    let loadingView: FeedLoadingView
    let feedView: FeedView
    
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedViewPresenter.self), comment: "")
    }
    
    public init(loadingView: FeedLoadingView, feedView: FeedView) {
        self.loadingView = loadingView
        self.feedView = feedView
    }
    
    public func didStartLoadingFeed() {
        loadingView.display(viewModel: .init(isLoading: true))
    }
    
    public func didLoadFeedWithError() {
        loadingView.display(viewModel: .init(isLoading: false))
    }
    
    public func didFinishLoadingFeed(feedItem: [FeedImage]) {
        loadingView.display(viewModel: .init(isLoading: false))
        feedView.display(viewModel: .init(feedItem: feedItem))
    }
}
