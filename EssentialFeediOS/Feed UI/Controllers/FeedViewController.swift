//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Luiz Diniz Hammerli on 31/12/21.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController {
    private var imageDataLoader: FeedImageDataLoader?
    var tableModel = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }
    private var feedRefreshController: FeedRefreshViewController?
    
    convenience init(refreshController: FeedRefreshViewController) {
        self.init()
        self.feedRefreshController = refreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
    }
    
    private func setupRefreshControl() {
        tableView.refreshControl = feedRefreshController?.view
        feedRefreshController?.refresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableModel[indexPath.item].view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableModel[indexPath.item].cancelLoad()
    }
}
