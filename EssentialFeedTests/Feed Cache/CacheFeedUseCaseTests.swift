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
    enum ReceivedMessages: Equatable {
        case deleteCachedFeeds
        case insertFeeds([FeedItem], Date)
    }
    
    private(set) var deletionCompletions: [((Error?) -> Void)] = []
    private(set) var messages: [ReceivedMessages] = []
    
    func deleteCachedItems(completion: @escaping (Error?) -> Void) {
        deletionCompletions.append(completion)
        messages.append(.deleteCachedFeeds)
    }
    
    func insertCachedItems(items: [FeedItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
        messages.append(.insertFeeds(items, timestamp))
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletion(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponUponCreation() {
        let feedStore = FeedStore()
        let _ = makeSut()
        
        XCTAssertTrue(feedStore.messages.isEmpty)
    }
    
    func test_init_requestCacheDeletion() {
        let (sut, feedStore) = makeSut()
        sut.save(items: [anyUniqueFeedItem(), anyUniqueFeedItem()])
        
        XCTAssertEqual(feedStore.messages, [.deleteCachedFeeds])
    }
    
    func test_init_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, feedStore) = makeSut()
        sut.save(items: [anyUniqueFeedItem(), anyUniqueFeedItem()])
        feedStore.completeDeletion(with: anyNSError())
                
        XCTAssertEqual(feedStore.messages, [.deleteCachedFeeds])
    }
    
    func test_init_requestNewCacheInsertioWithTimeStampOnSuccessfullDeletion() {
        let timeStamp = Date()
        let (sut, feedStore) = makeSut(currentDate: { timeStamp })
        let items = [anyUniqueFeedItem(), anyUniqueFeedItem()]
        sut.save(items: items)
        feedStore.completeDeletion()
                
        XCTAssertEqual(feedStore.messages, [.deleteCachedFeeds, .insertFeeds(items, timeStamp)])
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
