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
    
    func save(items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedItems() { [weak self] error in
            guard let self = self else { return }
            if error != nil {
                completion(error)
            } else {
                self.store.insertCachedItems(items: items, timestamp: self.currentDate(), completion: completion)
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
    private(set) var insertCompletions: [((Error?) -> Void)] = []
    private(set) var messages: [ReceivedMessages] = []
    
    func deleteCachedItems(completion: @escaping (Error?) -> Void) {
        deletionCompletions.append(completion)
        messages.append(.deleteCachedFeeds)
    }
    
    func insertCachedItems(items: [FeedItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
        messages.append(.insertFeeds(items, timestamp))
        insertCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletion(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertCompletions[index](nil)
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponUponCreation() {
        let feedStore = FeedStore()
        let _ = makeSut()
        
        XCTAssertTrue(feedStore.messages.isEmpty)
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, feedStore) = makeSut()
        sut.save(items: [anyUniqueFeedItem(), anyUniqueFeedItem()]) { _ in }
        
        XCTAssertEqual(feedStore.messages, [.deleteCachedFeeds])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, feedStore) = makeSut()
        sut.save(items: [anyUniqueFeedItem(), anyUniqueFeedItem()]) { _ in }
        feedStore.completeDeletion(with: anyNSError())
                
        XCTAssertEqual(feedStore.messages, [.deleteCachedFeeds])
    }
    
    func test_save_requestNewCacheInsertioWithTimeStampOnSuccessfullDeletion() {
        let timeStamp = Date()
        let (sut, feedStore) = makeSut(currentDate: { timeStamp })
        let items = [anyUniqueFeedItem(), anyUniqueFeedItem()]
        sut.save(items: items) { _ in }
        feedStore.completeDeletion()
                
        XCTAssertEqual(feedStore.messages, [.deleteCachedFeeds, .insertFeeds(items, timeStamp)])
    }
    
    func test_save_failsWithDeletionError() {
        let (sut, store) = makeSut()
        let expectedError = anyNSError()
        var receivedError: Error?
        
        let exp = expectation(description: "Wating for save")
        sut.save(items: [anyUniqueFeedItem(), anyUniqueFeedItem()]) { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletion(with: expectedError)
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual((receivedError as NSError?), expectedError)
    }
    
    func test_save_failsWithInsertionError() {
        let (sut, store) = makeSut()
        let expectedError = anyNSError()
        var receivedError: Error?
        
        let exp = expectation(description: "Wating for save")
        sut.save(items: [anyUniqueFeedItem(), anyUniqueFeedItem()]) { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletion()
        store.completeInsertion(with: expectedError)
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(store.insertCompletions.count, 1)
        XCTAssertEqual((receivedError as NSError?), expectedError)
    }
    
    func test_save_successed() {
        let (sut, store) = makeSut()
        var receivedError: Error?
        
        let exp = expectation(description: "Wating for save")
        sut.save(items: [anyUniqueFeedItem(), anyUniqueFeedItem()]) { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletion()
        store.completeInsertionSuccessfully()
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(store.insertCompletions.count, 1)
        XCTAssertNil(receivedError)
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
