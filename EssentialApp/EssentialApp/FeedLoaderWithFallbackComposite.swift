//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Luiz Hammerli on 20/02/22.
//

import EssentialFeed

public final class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primary: FeedLoader
    private let fallback: FeedLoader
    
    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure:
                self.fallback.load(completion: completion)
            }
        }
    }
}
