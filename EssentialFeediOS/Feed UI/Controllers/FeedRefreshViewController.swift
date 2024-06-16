//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Luiz Diniz Hammerli on 09/01/22.
//

import UIKit
import EssentialFeed

public protocol FeedRefreshViewControllerDelegate {
    func didRequestLoadFeed()
}

public final class FeedRefreshViewController: NSObject {
    var view: UIRefreshControl = UIRefreshControl()
    private let delegate: FeedRefreshViewControllerDelegate
    
    public init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
        super.init()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh() {
        delegate.didRequestLoadFeed()
    }
}

// MARK: - FeedLoadingView
extension FeedRefreshViewController: FeedLoadingView {
    public func display(viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
}
