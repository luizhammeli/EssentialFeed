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
    private var tableModel = [FeedImage]()
    
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
        loader?.load(completion: { [weak self] result in
            if let feedImage = try? result.get() {
                self?.tableModel = feedImage
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        })
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadFeed), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationLabel.text = tableModel[indexPath.item].location
        cell.descriptionLabel.text = tableModel[indexPath.item].description
        cell.locationLabel.isHidden = tableModel[indexPath.item].location == nil
        return cell
    }
}
