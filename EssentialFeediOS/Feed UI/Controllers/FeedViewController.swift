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
    var feedRefreshController: FeedRefreshViewController?
    var tableModel = [FeedImageCellController]() { didSet { tableView.reloadData() } }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = feedRefreshController?.view
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        feedRefreshController?.refresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableModel[indexPath.item].view(tableView: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableModel[indexPath.item].cancelLoad()
    }
}
