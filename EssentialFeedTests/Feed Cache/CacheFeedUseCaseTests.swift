//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Luiz Diniz Hammerli on 21/11/21.
//

import XCTest
import EssentialFeed

final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(items: [FeedItem]) {
        store.deleteCachedItems() { [weak self] error in
            guard let self = self else { return }
            if error != nil {
                return
            } else {
                self.store.insertCachedItems(items: items, timestamp: self.currentDate()) { _ in }
            }
        }
    }
}

final class FeedStore {
    private(set) var deletionCompletions: [((Error?) -> Void)] = []
    private(set) var insertions: [([FeedItem], Date)] = []
    
    func deleteCachedItems(completion: @escaping (Error?) -> Void) {
        deletionCompletions.append(completion)
    }
    
    func insertCachedItems(items: [FeedItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
        insertions.append((items, timestamp))
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletion(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let feedStore = FeedStore()
        let _ = makeSut()
        
        XCTAssertEqual(feedStore.deletionCompletions.count, 0)
    }
    
    func test_init_requestCacheDeletion() {
        let (sut, feedStore) = makeSut()
        sut.save(items: [anyUniqueFeedItem(), anyUniqueFeedItem()])
        
        XCTAssertEqual(feedStore.deletionCompletions.count, 1)
    }
    
    func test_init_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, feedStore) = makeSut()
        sut.save(items: [anyUniqueFeedItem(), anyUniqueFeedItem()])
        feedStore.completeDeletion(with: anyNSError())
        
        XCTAssertEqual(feedStore.insertions.count, 0)
    }
    
    func test_init_requestNewCacheInsertioWithTimeStampOnSuccessfullDeletion() {
        let timeStamp = Date()
        let (sut, feedStore) = makeSut(currentDate: { timeStamp })
        let items = [anyUniqueFeedItem(), anyUniqueFeedItem()]
        sut.save(items: items)
        feedStore.completeDeletion()
        
        XCTAssertEqual(feedStore.insertions.count, 1)
        XCTAssertEqual(feedStore.insertions.first?.1, timeStamp)
        XCTAssertEqual(feedStore.insertions.first? .0, items)
    }
}

// MARK: - Helpers

extension CacheFeedUseCaseTests {
    private func makeSut(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStore) {
        let feedStore = FeedStore()
        let sut = LocalFeedLoader(store: feedStore, currentDate: currentDate)
        checkForMemoryLeaks(instance: feedStore, file: file, line: line)
        checkForMemoryLeaks(instance: sut, file: file, line: line)
        return (sut, feedStore)
    }
    
    private func anyUniqueFeedItem() -> FeedItem {
        return .init(id: UUID(), imageURL: makeURL(), description: nil, location: nil)
    }
}
