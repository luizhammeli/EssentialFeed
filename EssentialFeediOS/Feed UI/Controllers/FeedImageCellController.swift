//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Luiz Diniz Hammerli on 09/01/22.
//

import UIKit
import EssentialFeed

final class FeedImageCellController {
    private var task: FeedImageDataLoaderTask?
    private let imageLoader: FeedImageDataLoader
    private let model: FeedImage
    
    init(for model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.imageLoader = imageLoader
        self.model = model
    }
    
    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        
        cell.locationLabel.isHidden = model.location == nil
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.retryButton.isHidden = true
        
        let url = model.url
        cell.feedImageContainer.startShimmering()
        
        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            self.task = self.imageLoader.loadFeedImageData(from: url) { [weak cell] result in
                cell?.feedImageView.image = (try? UIImage(data: result.get())) ?? nil
                cell?.feedImageContainer.stopShimmering()
                cell?.retryButton.isHidden = !(cell?.feedImageView.image == nil)
            }
        }
        
        cell.retryAction = loadImage
        loadImage()
        return cell
    }
    
    func cancelTask() {
        task?.cancel()
    }
    
    deinit {
        task?.cancel()
    }
}
