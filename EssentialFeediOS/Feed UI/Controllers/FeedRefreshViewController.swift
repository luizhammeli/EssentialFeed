//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Luiz Diniz Hammerli on 09/01/22.
//

import UIKit

public final class FeedRefreshViewController: NSObject {
    private(set) lazy var view: UIRefreshControl = loadView(UIRefreshControl())
    
    private let presenter: FeedViewPresenter
    
    public init(presenter: FeedViewPresenter) {
        self.presenter = presenter
    }
    
    @objc func refresh() {
        presenter.load()
    }
    
    private func loadView(_ view: UIRefreshControl) -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}

// MARK: - FeedLoadingView
extension FeedRefreshViewController: FeedLoadingView {
    func onChange(isLoading: Bool) {
        if isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
}
