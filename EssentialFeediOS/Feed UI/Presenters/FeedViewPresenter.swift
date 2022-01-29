//
//  FeedViewPresenter.swift
//  EssentialFeediOS
//
//  Created by Luiz Diniz Hammerli on 16/01/22.
//

import Foundation
import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

struct FeedViewModel {
    let feedItem: [FeedImage]
}

protocol FeedLoadingView: AnyObject {
    func display(viewModel: FeedLoadingViewModel)
}

protocol FeedView {
    func display(viewModel: FeedViewModel)
}

public final class FeedViewPresenter {
    var loadingView: FeedLoadingView?
    var feedView: FeedView?
    
    func didFinishLoadingFeed(feedItem: [FeedImage]) {
        loadingView?.display(viewModel: .init(isLoading: false))
        feedView?.display(viewModel: .init(feedItem: feedItem))
    }
    
    func didStartLoadingFeed() {
        loadingView?.display(viewModel: .init(isLoading: true))
    }
    
    func didLoadFeedWithError() {
        loadingView?.display(viewModel: .init(isLoading: false))
    }
}
