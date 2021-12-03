//
//  ValidadeCacheUseCaseTest.swift
//  EssentialFeedTests
//
//  Created by Luiz Diniz Hammerli on 28/11/21.
//

import XCTest
import EssentialFeed

final class ValidadeCacheUseCaseTest: XCTestCase {
    func test_init_doesNotMessageStoreUponUponCreation() {
        let (_, store) = makeSut()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_validateCache_deletesCacheOnValidadeError() {
        let (sut, store) = makeSut()
        sut.validateCache()
        store.completreRetreive(with: anyNSError())
        XCTAssertEqual(store.messages, [.retrive, .deleteCachedFeeds])
    }
    
    func test_validateCache_doesNotDeletesWithEmptyCache() {
        let (sut, store) = makeSut()
        sut.validateCache()
        store.completeRetriveWithEmptyData()
        XCTAssertEqual(store.messages, [.retrive])
    }
    
    func test_validateCache_doesNotDeletesOnNonExpiredCache() {
        let (sut, store) = makeSut()
        sut.validateCache()
        store.completeRetrive(with: anyUniqueFeedImages().localModels, timestamp: Date().add(days: -7).add(days: 1))
        XCTAssertEqual(store.messages, [.retrive])
    }
    
    func test_validateCache_deletesOnCacheExpiration() {
        let (sut, store) = makeSut()
        sut.validateCache()
        store.completeRetrive(with: anyUniqueFeedImages().localModels, timestamp: Date().add(days: -7))
        XCTAssertEqual(store.messages, [.retrive, .deleteCachedFeeds])
    }
    
    func test_validateCache_deletesOnExpiredCache() {
        let (sut, store) = makeSut()
        sut.validateCache()
        store.completeRetrive(with: anyUniqueFeedImages().localModels, timestamp: Date().add(days: -7).add(days: -1))
        XCTAssertEqual(store.messages, [.retrive, .deleteCachedFeeds])
    }
    
    func test_validateCache_doesNotDeletesIfSutInstanceHasBeenDealocated() {
        let feedStore = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: feedStore, currentDate: Date.init)
        sut?.validateCache()
        sut = nil
        feedStore.completreRetreive(with: anyNSError())
        XCTAssertEqual(feedStore.messages, [.retrive])
    }
}

// MARK: - Helpers
private extension ValidadeCacheUseCaseTest {
    private func makeSut(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let feedStore = FeedStoreSpy()
        let sut = LocalFeedLoader(store: feedStore, currentDate: currentDate)
        checkForMemoryLeaks(instance: feedStore, file: file, line: line)
        checkForMemoryLeaks(instance: sut, file: file, line: line)
        return (sut, feedStore)
    }
}
