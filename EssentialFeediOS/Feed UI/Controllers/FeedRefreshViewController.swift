//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Luiz Diniz Hammerli on 09/01/22.
//

import UIKit

public final class FeedRefreshViewController: NSObject {
    private(set) lazy var view: UIRefreshControl = binded(UIRefreshControl())
    
    private let viewModel: FeedViewModel
        
    public init(viewModel: FeedViewModel) {
        self.viewModel = viewModel                
    }
    
    @objc func refresh() {
        viewModel.load()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onChange = { [weak self] isLoading in
            if isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }        
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
