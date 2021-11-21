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
}

final class FeedStore {
    var deleteCacheFeedCallCount = 0
}

final class CacheFeedUseCaseTests: XCTestCase {
    func test_() {
        let feedStore = FeedStore()
        let _ = LocalFeedLoader(store: feedStore)
        
        XCTAssertEqual(feedStore.deleteCacheFeedCallCount, 0)
    }
}
