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
    private(set) lazy var view: UIRefreshControl = loadView(UIRefreshControl())
    
    private let delegate: FeedRefreshViewControllerDelegate
    
    public init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
    
    @objc func refresh() {
        delegate.didRequestLoadFeed()
    }
    
    private func loadView(_ view: UIRefreshControl) -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
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
