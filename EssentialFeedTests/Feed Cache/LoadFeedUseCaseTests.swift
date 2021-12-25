//
//  LoadFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Luiz Diniz Hammerli on 25/11/21.
//

import XCTest
import EssentialFeed

final class LoadFeedUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponUponCreation() {
        let (_, store) = makeSut()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_load_requestCacheRetreival() {
        let (sut, store) = makeSut()
        sut.load() { _ in }
        XCTAssertEqual(store.messages , [.retrive])
    }
    
    func test_load_hasNoSideEffectOnRetreivalError() {
        let (sut, store) = makeSut()
        sut.load() { _ in }
        store.completreRetreive(with: anyNSError())
        XCTAssertEqual(store.messages , [.retrive])
    }
    
    func test_load_hasNoSideEffectOnEmptyCache() {
        let (sut, store) = makeSut()
        sut.load() { _ in }
        store.completeRetriveWithEmptyData()
        XCTAssertEqual(store.messages, [.retrive])
    }
    
    func test_load_hasNoSideEffectOnNonExpiredCache() {
        let (sut, store) = makeSut()
        sut.load() { _ in }
        store.completeRetrive(with: anyUniqueFeedImages().localModels, timestamp: Date().minusFeedCacheMaxAge().add(seconds: 1))
        XCTAssertEqual(store.messages , [.retrive])
    }
    
    func test_load_hasNoSideEffectOnCacheExpiration() {
        let (sut, store) = makeSut()
        sut.load() { _ in }
        store.completeRetrive(with: anyUniqueFeedImages().localModels, timestamp: Date().minusFeedCacheMaxAge())
        XCTAssertEqual(store.messages , [.retrive])
    }    
    
    func test_load_hasNoSideEffectOnExpiredCache() {
        let (sut, store) = makeSut()
        sut.load() { _ in }
        store.completeRetrive(with: anyUniqueFeedImages().localModels, timestamp: Date().minusFeedCacheMaxAge().add(seconds: -1))
        XCTAssertEqual(store.messages , [.retrive])
    }
    
    func test_load_failsWithRetreivalError() {
        let expectedError = anyNSError()
        let (sut, store) = makeSut()
        expect(sut: sut, with: .failure(expectedError)) {
            store.completreRetreive(with: expectedError)
        }
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSut()
        expect(sut: sut, with: .success([])) {
            store.completeRetriveWithEmptyData()
        }
    }
    
    func test_load_deliversImagesOnNonExpiredCache() {
        let (sut, store) = makeSut()
        let images = anyUniqueFeedImages()
        expect(sut: sut, with: .success(images.models)) {
            store.completeRetrive(with: images.localModels, timestamp: Date().minusFeedCacheMaxAge().add(seconds: 1))
        }
    }
    
    func test_load_deliversNoImagesOnCacheExpiration() {
        let (sut, store) = makeSut()
        let images = anyUniqueFeedImages()
        expect(sut: sut, with: .success([])) {
            store.completeRetrive(with: images.localModels, timestamp: Date().minusFeedCacheMaxAge())
        }
    }
    
    func test_load_deliversNoImagesOnExpiredCache() {
        let (sut, store) = makeSut()
        let images = anyUniqueFeedImages()
        expect(sut: sut, with: .success([])) {
            store.completeRetrive(with: images.localModels, timestamp: Date().minusFeedCacheMaxAge().add(seconds: -1))
        }
    }
    
    func test_load_deliversNoImagesIfSutHasBeenDealocated() {
        let feedStore = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: feedStore, currentDate: Date.init)
        var items: [FeedLoader.Result] = []
        sut?.load(completion: { items.append($0) })
        sut = nil
        feedStore.completeRetrive(with: anyUniqueFeedImages().localModels, timestamp: Date().minusFeedCacheMaxAge())
        XCTAssertTrue(items.isEmpty)
    }
}

// MARK: - Helpers
private extension LoadFeedUseCaseTests {
    private func makeSut(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let feedStore = FeedStoreSpy()
        let sut = LocalFeedLoader(store: feedStore, currentDate: currentDate)
        checkForMemoryLeaks(instance: feedStore, file: file, line: line)
        checkForMemoryLeaks(instance: sut, file: file, line: line)
        return (sut, feedStore)
    }
    
    private func expect(sut: LocalFeedLoader, with expectedResult: FeedLoader.Result, when action: @escaping () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Waiting for completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(let receivedImages), .success(let expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
            case (.failure(let receivedError as NSError), .failure(let expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Should complete with \(expectedResult) instead \(receivedResult).", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
