//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Luiz Diniz Hammerli on 31/12/21.
//

import UIKit
import EssentialFeed

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    func loadFeedImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> FeedImageDataLoaderTask
}

public final class FeedViewController: UITableViewController {
    private var feedLoader: FeedLoader? = nil
    private var imageDataLoader: FeedImageDataLoader? = nil
    private var tableModel = [FeedImage]()
    private var imageDataTasks = [URL: FeedImageDataLoaderTask]()
    
    public convenience init(feedLoader: FeedLoader, imageDataLoader: FeedImageDataLoader?) {
        self.init()
        self.feedLoader = feedLoader
        self.imageDataLoader = imageDataLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
        loadFeed()
    }
    
    @objc private func loadFeed() {
        refreshControl?.beginRefreshing()
        feedLoader?.load(completion: { [weak self] result in
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
        
        cell.locationLabel.isHidden = tableModel[indexPath.item].location == nil
        cell.locationLabel.text = tableModel[indexPath.item].location
        cell.descriptionLabel.text = tableModel[indexPath.item].description
        
        let url = tableModel[indexPath.item].url
        cell.feedImageContainer.startShimmering()
        imageDataTasks[url] = imageDataLoader?.loadFeedImageData(from: url) { [weak cell] result in
            cell?.feedImageView.image = (try? UIImage(data: result.get())) ?? nil
            cell?.feedImageContainer.stopShimmering()
            cell?.retryButton.isHidden = !(cell?.feedImageView.image == nil)
        }
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let url = tableModel[indexPath.item].url
        imageDataTasks[url]?.cancel()
    }
}
