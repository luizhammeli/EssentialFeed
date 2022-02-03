//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Luiz Diniz Hammerli on 01/01/22.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    @IBOutlet public weak var descriptionLabel: UILabel!
    @IBOutlet public weak var locationLabel: UILabel!
    @IBOutlet public weak var feedImageView: UIImageView!
    @IBOutlet public weak var feedImageContainer: UIView!
    @IBOutlet public weak var retryButton: UIButton!
    
    @IBAction private func didPressRetryButton() {
        onRetry?()
    }
    
    var onRetry: (() -> Void)?
}
