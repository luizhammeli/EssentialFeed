//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Luiz Diniz Hammerli on 09/01/22.
//

import UIKit

protocol FeedImageCellControllerDelegate {
     func didRequestImage()
     func didCancelImageRequest()
 }

final class FeedImageCellController {
    private var delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueCell(with: "FeedImageCell")
        delegate.didRequestImage()
        return cell!
    }
    
    func preload() {
         delegate.didRequestImage()
     }

     func cancelLoad() {
         releaseCellForReuse() 
         delegate.didCancelImageRequest()
     }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}

extension FeedImageCellController: FeedImageView {
    typealias Image = UIImage
    
    func display(model: FeedCellViewModel<UIImage>) {
        cell?.locationLabelsContainer.isHidden = model.locationIsHidden
        cell?.locationLabel.text = model.location
        cell?.descriptionLabel.text = model.description
        cell?.onRetry = delegate.didRequestImage
        cell?.feedImageView.image = model.image
        cell?.retryButton.isHidden = !model.shouldRetry
        
        if model.isLoading {
            self.cell?.feedImageView.alpha = 0            
            cell?.activityIndicator.startAnimating()
        } else {
            cell?.activityIndicator.stopAnimating()
            if model.image != nil {
                UIView.animate(withDuration: 0.25) {
                    self.cell?.feedImageView.alpha = 1
                }
            }
        }
    }
}
