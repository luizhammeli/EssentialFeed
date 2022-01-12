//
//  FeedImageCellViewModel.swift
//  EssentialFeediOS
//
//  Created by Luiz Diniz Hammerli on 10/01/22.
//

import Foundation
import EssentialFeed

public final class FeedImageCellViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    private var task: FeedImageDataLoaderTask?
    private let imageLoader: FeedImageDataLoader
    private let model: FeedImage
        
    var onImageLoadChangeState: Observer<Bool>?
    var shouldRetryImageLoadStateChange: Observer<Bool>?
    var onImageLoad: ((Image) -> Void)?
    let imageInit: (Data) -> Image?
    
    public init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.imageLoader = imageLoader
        self.model = model
        self.imageInit = imageTransformer
    }
    
    var location: String? {
        model.location
    }
    
    var description: String? {
        model.description
    }
    
    var hideLocation: Bool {
        model.location == nil
    }
    
    func loadImage() {
        onImageLoadChangeState?(true)
        shouldRetryImageLoadStateChange?(false)
        self.task = self.imageLoader.loadFeedImageData(from: model.url) { [weak self] result in
            if let image = try? self?.imageInit(result.get()) {
                self?.onImageLoad?(image)
            } else {
                self?.shouldRetryImageLoadStateChange?(true)
            }
            self?.onImageLoadChangeState?(false)
        }
    }
    
    func cancelTask() {
        task?.cancel()
    }
}

