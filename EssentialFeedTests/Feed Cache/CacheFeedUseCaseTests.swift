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
        sut.save(images: anyUniqueFeedImages().models) { _ in }
        
        XCTAssertEqual(feedStore.messages, [.deleteCachedFeeds])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, feedStore) = makeSut()
        sut.save(images: anyUniqueFeedImages().models) { _ in }
        feedStore.completeDeletion(with: anyNSError())
                
        XCTAssertEqual(feedStore.messages, [.deleteCachedFeeds])
    }
    
    func test_save_requestNewCacheInsertioWithTimeStampOnSuccessfullDeletion() {
        let timeStamp = Date()
        let (sut, feedStore) = makeSut(currentDate: { timeStamp })
        let items = anyUniqueFeedImages()
        sut.save(images: items.models) { _ in }
        feedStore.completeDeletion()
                
        XCTAssertEqual(feedStore.messages, [.deleteCachedFeeds, .insertFeeds(items.localModels, timeStamp)])
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
        var receivedValue: [LocalFeedLoader.SaveResult] = []
        let feedStore = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: feedStore, currentDate: Date.init)
                
        sut?.save(images: anyUniqueFeedImages().models) { receivedValue.append($0!) }
        sut = nil
        feedStore.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedValue.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDealocated() {
        var receivedValue: [LocalFeedLoader.SaveResult] = []
        let feedStore = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: feedStore, currentDate: Date.init)
                
        sut?.save(images: anyUniqueFeedImages().models) { receivedValue.append($0!) }
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
        var receivedErrors: [Error?] = []
        
        let exp = expectation(description: "Wating for save")
        sut.save(images: anyUniqueFeedImages().models) { error in
            receivedErrors.append(error)
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(receivedErrors.count, 1)
        XCTAssertEqual((receivedErrors[0] as NSError?), (expectedError as NSError?), file: file, line: line)
    }
}
