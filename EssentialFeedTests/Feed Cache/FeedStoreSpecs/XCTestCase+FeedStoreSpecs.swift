//
//  XCTest+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Luiz Diniz Hammerli on 24/12/21.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    func expect(sut: FeedStore, toRetriveTwice result: FeedStore.RetrievedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut: sut, with: result)
        expect(sut: sut, with: result)
    }
    
    func expect(sut: FeedStore, with expectedResult: FeedStore.RetrievedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Waiting for request")
        
        sut.retrive { receivedResult in
            switch (receivedResult, expectedResult) {
                
            case let (.success(.some((receivedItems, receivedDate))), .success(.some((expectedItems, expectedDate)))):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                XCTAssertEqual(receivedDate, expectedDate, file: file, line: line)
                
            case (.success(nil), .success(nil)), (.failure, .failure): break
                
            default:
                XCTFail("Expected \(expectedResult) result got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    @discardableResult
    func insert(sut: FeedStore, items: [LocalFeedItem], timestamp: Date) -> Error? {
        let expectation = expectation(description: "Waiting for request")
        var expectedError: Error?
        sut.insert(items: items, timestamp: timestamp) { error in
            expectedError = error
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        return expectedError
    }
    
    func deleteCache(sut: FeedStore) -> Error? {
        var expectedError: Error?
        let expectation = expectation(description: "Waiting for deletion")
        
        sut.deleteCachedItems { error in
            expectedError = error
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10 )
        return expectedError
    }
}

