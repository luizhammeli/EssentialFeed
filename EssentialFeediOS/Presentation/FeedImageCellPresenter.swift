//
//  FeedImageCellPresenter.swift
//  EssentialFeediOS
//
//  Created by Luiz Hammerli on 30/01/22.
//

import Foundation
import EssentialFeed

public protocol FeedImageView {
    associatedtype Image
    func display(model: FeedCellViewModel<Image>)
}

public struct FeedCellViewModel<Image> {
    let location: String?
    let description: String?
    let isLoading: Bool
    let shouldRetry: Bool
    let image: Image?
    
    var locationIsHidden: Bool {
        location == nil
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
    
    func didStartLoading(model: FeedImage) {
        let viewModel = FeedCellViewModel<Image>(location: model.location,
                                                 description: model.description,
                                                 isLoading: true,
                                                 shouldRetry: false,
                                                 image: nil)
        view.display(model: viewModel)        
    }
    
    func didFinishLoadingWithError(model: FeedImage) {
        let viewModel = FeedCellViewModel<Image>(location: model.location,
                                                 description: model.description,
                                                 isLoading: false,
                                                 shouldRetry: true,
                                                 image: nil)
        view.display(model: viewModel)
    }
    
    func didFinishLoadingWithSuccess(model: FeedImage, imageData: Data) {
        let image = imageTransformer(imageData)
        let viewModel = FeedCellViewModel<Image>(location: model.location,
                                                 description: model.description,
                                                 isLoading: false,
                                                 shouldRetry: image == nil,
                                                 image: image)
        view.display(model: viewModel)
    }
}

