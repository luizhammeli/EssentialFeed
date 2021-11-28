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
    
    func test_load_deletesCacheOnRetreivalError() {
        let (sut, store) = makeSut()
        sut.load() { _ in }
        store.completreRetreive(with: anyNSError())
        XCTAssertEqual(store.messages , [.retrive, .deleteCachedFeeds])
    }
    
    func test_load_doesNotDeletesCacheOnEmptyCache() {
        let (sut, store) = makeSut()
        sut.load() { _ in }
        store.completeRetriveWithEmptyData()
        XCTAssertEqual(store.messages , [.retrive])
    }
    
    func test_load_doesNotDeletesCacheWithLessThanSevenDaysOldCache() {
        let (sut, store) = makeSut()
        sut.load() { _ in }
        store.completeRetrive(with: anyUniqueFeedImages().localModels, timestamp: Date().add(days: -6))
        XCTAssertEqual(store.messages , [.retrive])
    }
    
    func test_load_deletesCacheWithMoreThanSevenDaysOldCache() {
        let (sut, store) = makeSut()
        sut.load() { _ in }
        store.completeRetrive(with: anyUniqueFeedImages().localModels, timestamp: Date().add(days: -8))
        XCTAssertEqual(store.messages , [.retrive, .deleteCachedFeeds])
    }
    
    func test_load_deletesCacheWithSevenDaysOldCache() {
        let (sut, store) = makeSut()
        sut.load() { _ in }
        store.completeRetrive(with: anyUniqueFeedImages().localModels, timestamp: Date().add(days: -7))
        XCTAssertEqual(store.messages , [.retrive, .deleteCachedFeeds])
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
    
    func test_load_deliversImagesOnLessThanSevenDaysOldCache() {
        let (sut, store) = makeSut()
        let images = anyUniqueFeedImages()
        expect(sut: sut, with: .success(images.models)) {
            store.completeRetrive(with: images.localModels, timestamp: Date().add(days: -7).add(seconds: 1))
        }
    }
    
    func test_load_deliversNoImagesWithSevenDaysOldCache() {
        let (sut, store) = makeSut()
        let images = anyUniqueFeedImages()
        expect(sut: sut, with: .success([])) {
            store.completeRetrive(with: images.localModels, timestamp: Date().add(days: -7))
        }
    }
    
    func test_load_deliversNoImagesWithMoreThanSevenDaysOldCache() {
        let (sut, store) = makeSut()
        let images = anyUniqueFeedImages()
        expect(sut: sut, with: .success([])) {
            store.completeRetrive(with: images.localModels, timestamp: Date().add(days: -7).add(days: -1))
        }
    }
    
    func test_load_deliversNoImagesIfSutHasBeenDealocated() {
        let feedStore = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: feedStore, currentDate: Date.init)
        var items: [LoadFeedResult] = []
        sut?.load(completion: { items.append($0) })
        sut = nil
        feedStore.completeRetrive(with: anyUniqueFeedImages().localModels, timestamp: Date().add(days: -3))
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
    
    private func expect(sut: LocalFeedLoader, with expectedResult: LoadFeedResult, when action: @escaping () -> Void, file: StaticString = #filePath, line: UInt = #line) {
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

private extension Date {
    func add(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func add(seconds: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .second, value: seconds, to: self)!
    }
}
