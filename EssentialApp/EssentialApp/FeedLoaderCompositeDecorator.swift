//
//  FeedLoaderCompositeDecorator.swift
//  EssentialApp
//
//  Created by Luiz Diniz Hammerli on 24/03/22.
//

import Foundation
import EssentialFeed

public final class FeedLoaderCompositeDecorator {
    private let feedLoader: FeedLoader
    private let feedCache: FeedCache
    
    public init(feedLoader: FeedLoader, feedCache: FeedCache) {
        self.feedLoader = feedLoader
        self.feedCache = feedCache
    }
}

extension FeedLoaderCompositeDecorator: FeedLoader {
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        feedLoader.load { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.saveFeedIgnoringCompletion(data: data)
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func saveFeedIgnoringCompletion(data: [FeedImage]) {
        feedCache.save(images: data, completion: { _ in })
    }
}
