//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Luiz Diniz Hammerli on 24/11/21.
//

import Foundation

public final class LocalFeedLoader {
    public typealias SaveResult = Error?
    private let store: FeedStore
    private let currentDate: () -> Date
    private let calendar = Calendar(identifier: .gregorian)
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
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
    
    public func load(completion: @escaping (LoadFeedResult) -> Void) {
        self.store.retrive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .found(let items, let timestamp) where self.isValid(timestamp) :
                completion(.success(items.toModels()))
            case .failure(let error):
                completion(.failure(error))
            case .empty, .found:
                completion(.success([]))
            }
        }
    }
    
    public func validateCache() {
        self.store.retrive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedItems(completion: { _ in })
            case .found(_, let timestamp) where !self.isValid(timestamp):
                self.store.deleteCachedItems(completion: { _ in })
            case .empty, .found: break
            }
        }
    }
    
    private func cache(_ images: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        self.store.insert(items: images.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
    
    private var maxCacheAgeInDays: Int {
        return 7
    }
    
    private func isValid(_ timestamp: Date) -> Bool {
        guard let limitDate = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        return currentDate() < limitDate
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
