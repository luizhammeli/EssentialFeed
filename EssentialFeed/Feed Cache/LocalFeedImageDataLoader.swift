//
//  LocalFeedImageDataLoader.swift
//  EssentialFeedTests
//
//  Created by Luiz Hammerli on 27/03/22.
//

import Foundation

public final class LocalFeedImageDataLoaderTask: FeedImageDataLoaderTask {
    public func cancel() {}
}

public final class LocalFeedImageDataLoader: FeedImageDataLoader {
    public let feedStore: FeedImageStore
    
    public init(feedStore: FeedImageStore) {
        self.feedStore = feedStore
    }
    
    @discardableResult
    public func loadFeedImageData(from url: URL,
                           completion: @escaping (Result<Data, Error>) -> Void) -> FeedImageDataLoaderTask {
        feedStore.retrive(url: url) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                completion(.success(data))
            }
        }
        return LocalFeedImageDataLoaderTask()
    }
    
    public func save(with url: URL, data: Data) {
        feedStore.insert(url: url, data: data)
    }
}
