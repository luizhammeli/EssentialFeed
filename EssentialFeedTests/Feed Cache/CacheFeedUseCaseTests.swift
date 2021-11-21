//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Luiz Diniz Hammerli on 21/11/21.
//

import XCTest
import EssentialFeed

final class LocalFeedLoader {
    var store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(items: [FeedItem]) {
        store.deleteCachedItems()
    }
}

final class FeedStore {
    private(set) var deleteCacheFeedCallCount = 0
    
    func deleteCachedItems() {
        deleteCacheFeedCallCount += 1
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let feedStore = FeedStore()
        let _ = LocalFeedLoader(store: feedStore)
        
        XCTAssertEqual(feedStore.deleteCacheFeedCallCount, 0)
    }
    
    func test_init_requestCacheDeletion() {
        let feedStore = FeedStore()
        let sut = LocalFeedLoader(store: feedStore)
        sut.save(items: [anyUniqueFeedItem(), anyUniqueFeedItem()])
        
        XCTAssertEqual(feedStore.deleteCacheFeedCallCount, 1)
    }
}

// MARK: - Helpers

extension CacheFeedUseCaseTests {
    private func makeSut() -> (LocalFeedLoader, FeedStore) {
        let feedStore = FeedStore()
        let sut = LocalFeedLoader(store: feedStore)
        return (sut, feedStore)
    }
    
    private func anyUniqueFeedItem() -> FeedItem {
        return .init(id: UUID(), imageURL: makeURL(), description: nil, location: nil)
    }
}
