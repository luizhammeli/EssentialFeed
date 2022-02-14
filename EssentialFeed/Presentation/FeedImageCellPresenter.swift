//
//  FeedImageCellPresenter.swift
//  EssentialFeed
//
//  Created by Luiz Hammerli on 13/02/22.
//

import Foundation

public protocol FeedImageView {
    associatedtype Image: Equatable
    func display(model: FeedCellViewModel<Image>)
}

public struct FeedCellViewModel<Image: Equatable>: Equatable {
    let location: String?
    let description: String?
    let isLoading: Bool
    let shouldRetry: Bool
    let image: Image?
    
    public var locationIsHidden: Bool {
        location == nil
    }
    
    public init(location: String?, description: String?, isLoading: Bool, shouldRetry: Bool, image: Image?) {
        self.location = location
        self.description = description
        self.isLoading = isLoading
        self.shouldRetry = shouldRetry
        self.image = image
    }
}

public final class FeedImageCellPresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?
    let imageInit: (Data) -> Image?
    
    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.imageInit = imageTransformer
        self.imageTransformer = imageTransformer
        self.view = view
    }
    
    public func didStartLoading(model: FeedImage) {
        let viewModel = FeedCellViewModel<Image>(location: model.location,
                                                 description: model.description,
                                                 isLoading: true,
                                                 shouldRetry: false,
                                                 image: nil)
        view.display(model: viewModel)
    }
    
    public func didFinishLoadingWithError(model: FeedImage) {
        let viewModel = FeedCellViewModel<Image>(location: model.location,
                                                 description: model.description,
                                                 isLoading: false,
                                                 shouldRetry: true,
                                                 image: nil)
        view.display(model: viewModel)
    }
    
    public func didFinishLoadingWithSuccess(model: FeedImage, imageData: Data) {
        let image = imageTransformer(imageData)
        let viewModel = FeedCellViewModel<Image>(location: model.location,
                                                 description: model.description,
                                                 isLoading: false,
                                                 shouldRetry: image == nil,
                                                 image: image)
        view.display(model: viewModel)
    }
}
