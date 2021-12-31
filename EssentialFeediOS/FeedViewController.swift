//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Luiz Diniz Hammerli on 31/12/21.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController {
    private var loader: FeedLoader? = nil
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
        loadFeed()
    }
    
    @objc private func loadFeed() {
        refreshControl?.beginRefreshing()
        loader?.load(completion: { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        })
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadFeed), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
}
