//
//  FeedImageCell.swift
//  Prototype
//
//  Created by Luiz Diniz Hammerli on 26/12/21.
//

import UIKit

final class FeedImageCell: UITableViewCell {
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pinImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        feedImageView.alpha = 0
    }
    
    func setData(viewModel: FeedImageViewModel) {
        locationLabel.text = viewModel.location
        descriptionLabel.text = viewModel.description
        pinImage.isHidden = (viewModel.location == nil || viewModel.location?.isEmpty == true)
        descriptionLabel.isHidden = viewModel.description == nil
        
        feedImageView.image = UIImage(named: viewModel.imageName)
        UIView.animate(withDuration: 0.4, delay: 0.3, options: .curveEaseOut) { [weak self] in
            self?.feedImageView.alpha = 1
        } completion: { _ in }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        feedImageView.alpha = 0
        
    }
}
