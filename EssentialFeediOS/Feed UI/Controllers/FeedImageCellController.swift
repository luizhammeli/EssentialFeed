//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Luiz Diniz Hammerli on 09/01/22.
//

import UIKit

final class FeedImageCellController {
    private var viewModel: FeedImageCellViewModel<UIImage>
    
    init(viewModel: FeedImageCellViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view() -> UITableViewCell {
        let cell = bind(FeedImageCell())
        viewModel.loadImage()
        return cell
    }
    
    private func bind(_ cell: FeedImageCell) -> FeedImageCell {
        cell.locationLabel.isHidden = viewModel.hideLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description        
        cell.onRetry = viewModel.loadImage
        
        viewModel.onImageLoadChangeState = { [weak cell] isLoading in
            if isLoading {
                cell?.feedImageContainer.startShimmering()
            } else {
                cell?.feedImageContainer.stopShimmering()
            }
        }
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.feedImageView.image = image
        }
        
        viewModel.shouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            cell?.retryButton.isHidden = !shouldRetry
        }
        
        return cell
    }
    
    func cancelTask() {
        viewModel.cancelTask()
    }
}
