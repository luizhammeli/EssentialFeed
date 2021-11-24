//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Luiz Diniz Hammerli on 21/11/21.
//

import XCTest
import EssentialFeed

final class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponUponCreation() {
        let (_, store) = makeSut()
        
        XCTAssertTrue(store.messages.isEmpty)
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
        expect(sut, toCompletewith: expectedError) {
            store.completeDeletion(with: expectedError)
        }
    }
    
    func test_save_failsWithInsertionError() {
        let (sut, store) = makeSut()
        let expectedError = anyNSError()
        expect(sut, toCompletewith: expectedError) {
            store.completeDeletion()
            store.completeInsertion(with: expectedError)
        }
    }
    
    func test_save_successedOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSut()
        expect(sut, toCompletewith: nil) {
            store.completeDeletion()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDealocated() {
        var receivedValue: [Error] = []
        let feedStore = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: feedStore, currentDate: Date.init)
                
        sut?.save(items: [anyUniqueFeedItem()]) { receivedValue.append($0!) }
        sut = nil
        feedStore.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedValue.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDealocated() {
        var receivedValue: [Error] = []
        let feedStore = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: feedStore, currentDate: Date.init)
                
        sut?.save(items: [anyUniqueFeedItem()]) { receivedValue.append($0!) }
        feedStore.completeDeletion()
        sut = nil
        feedStore.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(receivedValue.isEmpty)
    }
}

// MARK: - Helpers

extension CacheFeedUseCaseTests {
    private func makeSut(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let feedStore = FeedStoreSpy()
        let sut = LocalFeedLoader(store: feedStore, currentDate: currentDate)
        checkForMemoryLeaks(instance: feedStore, file: file, line: line)
        checkForMemoryLeaks(instance: sut, file: file, line: line)
        return (sut, feedStore)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompletewith expectedError: Error?, when action: @escaping () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var receivedError: Error?
        
        let exp = expectation(description: "Wating for save")
        sut.save(items: [anyUniqueFeedItem(), anyUniqueFeedItem()]) { error in
            receivedError = error
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1)
        XCTAssertEqual((receivedError as NSError?), (expectedError as NSError?), file: file, line: line)
    }
    
    
    private final class FeedStoreSpy: FeedStore {
        enum ReceivedMessages: Equatable {
            case deleteCachedFeeds
            case insertFeeds([FeedItem], Date)
        }
        
        private(set) var deletionCompletions: [FeedStore.DeletionCompletion] = []
        private(set) var insertCompletions: [FeedStore.InsertionCompletion] = []
        private(set) var messages: [ReceivedMessages] = []
        
        func deleteCachedItems(completion: @escaping FeedStore.DeletionCompletion) {
            deletionCompletions.append(completion)
            messages.append(.deleteCachedFeeds)
        }
        
        func insert(items: [FeedItem], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
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
}
