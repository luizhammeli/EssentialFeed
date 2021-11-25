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
    
    func test_init_requestCacheRetreive() {
        let (sut, store) = makeSut()
        sut.load() { _ in }
        XCTAssertEqual(store.messages , [.retreive])
    }
    
    func test_init_loadFailsWithRetreiveError() {
        var receivedErrors = [Error?]()
        let expectedError = anyNSError()
        let (sut, store) = makeSut()
        
        sut.load { receivedErrors.append($0) }
        
        store.completreRetreive(with: expectedError)
        XCTAssertEqual(receivedErrors as? [NSError], [expectedError])
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
}
