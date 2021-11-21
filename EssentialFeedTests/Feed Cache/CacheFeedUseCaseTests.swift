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
        store.deleteCachedItems() { [weak self] error in
            guard let self = self else { return }
            if error != nil {
                return
            } else {
                self.store.insertCachedItems() { _ in }
            }
        }
    }
}

final class FeedStore {
    private(set) var deleteCacheFeedCallCount = 0
    private(set) var insertCacheFeedCallCount = 0
    private var completions: [((Error?) -> Void)] = []
    
    func deleteCachedItems(completion: @escaping (Error?) -> Void) {
        deleteCacheFeedCallCount += 1
        completions.append(completion)
    }
    
    func insertCachedItems(completion: @escaping (Error?) -> Void) {
        insertCacheFeedCallCount += 1
        //completions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        completions[index](error)
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
    
    func test_init_doesNotRequestCacheInsertionOnDeletionError() {
        let feedStore = FeedStore()
        let sut = LocalFeedLoader(store: feedStore)
        sut.save(items: [anyUniqueFeedItem(), anyUniqueFeedItem()])
        feedStore.completeDeletion(with: anyNSError())
        
        XCTAssertEqual(feedStore.insertCacheFeedCallCount, 0)
    }
}

// MARK: - Helpers

extension CacheFeedUseCaseTests {
    private func makeSut(file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStore) {
        let feedStore = FeedStore()
        let sut = LocalFeedLoader(store: feedStore)
        checkForMemoryLeaks(instance: feedStore, file: file, line: line)
        checkForMemoryLeaks(instance: sut, file: file, line: line)
        return (sut, feedStore)
    }
    
    private func anyUniqueFeedItem() -> FeedItem {
        return .init(id: UUID(), imageURL: makeURL(), description: nil, location: nil)
    }
}
