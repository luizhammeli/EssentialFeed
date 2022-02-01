//
//  FeedImageCellPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Luiz Hammerli on 30/01/22.
//

import Foundation
import EssentialFeed

public final class FeedImageCellPresentationAdapter<View: FeedImageView, Image> where View.Image == Image {
    private var task: FeedImageDataLoaderTask?
    private let imageLoader: FeedImageDataLoader
    private let model: FeedImage
    var presenter: FeedImageCellPresenter<View, Image>?
    
    public init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.imageLoader = imageLoader
        self.model = model
    }
    
    func loadImage() {
        let model = self.model
        presenter?.didStartLoading(model: model)
        self.task = self.imageLoader.loadFeedImageData(from: model.url) { [weak self] result in
            switch result {
            case .success(let data):
                self?.presenter?.didFinishLoadingWithSuccess(model: model, imageData: data)
            case .failure:
                self?.presenter?.didFinishLoadingWithError(model: model)
            }
        }
    }
}

extension FeedImageCellPresentationAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
        loadImage()
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
}
