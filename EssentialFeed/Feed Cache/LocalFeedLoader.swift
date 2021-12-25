//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Luiz Diniz Hammerli on 24/11/21.
//

import Foundation

public final class LocalFeedLoader: FeedLoader {
    public typealias SaveResult = Error?
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

// MARK: - Save
extension LocalFeedLoader {
    public func save(images: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedItems() { [weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(images, with: completion)
            }
        }
    }
    
    private func cache(_ images: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        self.store.insert(items: images.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

// MARK: - Load
extension LocalFeedLoader {
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        self.store.retrive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(.some((items, timestamp))) where FeedCachePolicy.isValid(timestamp, against: self.currentDate()):
                completion(.success(items.toModels()))
            case .failure(let error):
                completion(.failure(error))
            case .success:
                completion(.success([]))
            }
        }
    }
}

// MARK: - Validade Cache
extension LocalFeedLoader {
    public func validateCache() {
        self.store.retrive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedItems(completion: { _ in })
            case let .success(.some((_, timestamp))) where !FeedCachePolicy.isValid(timestamp, against: self.currentDate()):
                self.store.deleteCachedItems(completion: { _ in })
            case .success: break
            }
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedItem] {
        map { LocalFeedItem(id: $0.id, imageURL: $0.url, description: $0.description, location: $0.location) }
    }
}

private extension Array where Element == LocalFeedItem {
    func toModels() -> [FeedImage] {
        map { FeedImage(id: $0.id, url: $0.imageURL, description: $0.description, location: $0.location) }
    }
}
