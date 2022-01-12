//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Luiz Diniz Hammerli on 01/01/22.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    public let descriptionLabel = UILabel()
    public let locationLabel = UILabel()
    public let feedImageView = UIImageView()
    public let feedImageContainer = UIView()
    public lazy var retryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didPressRetryButton), for: .touchUpInside)
        return button
    }()
    
    @objc private func didPressRetryButton() {
        onRetry?()
    }
    
    var onRetry: (() -> Void)?
}
