//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Luiz Diniz Hammerli on 24/12/21.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {
    private let fileName = "\(type(of: self))"
    
    override func setUp() {
        super.setUp()
        deletesTestCache(fileName: fileName)
    }
    
    func test_load_completesWithEmptyArrayWhenCacheIsEmpty() {
        expect(sut: makeSut(), with: [])
    }
    
    func test_save_completesWithCorrectDataWhenCacheIsNotEmpty() {
        let sut = makeSut()
        let feedItems = anyUniqueFeedImages()
        
        save(sut: sut, models: feedItems.models)
        expect(sut: sut, with: feedItems.models)
    }
    
    func test_delete_completesWithEmptyDataWhenCacheIsEmptyAfterDeletion() {
        let sut = makeSut()
        let feedItems = anyUniqueFeedImages()
        
        save(sut: sut, models: feedItems.models)
        deletesTestCache(fileName: fileName)
        expect(sut: sut, with: [])
    }
}

private extension EssentialFeedCacheIntegrationTests {
    func makeSut(currentDate: @escaping (() -> Date) = Date.init) -> LocalFeedLoader {
        let store = CodableFeedStore(storeURL: testSpecificStoreURL(fileName: fileName))
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        checkForMemoryLeaks(instance: sut)
        
        return sut
    }
    
    @discardableResult
    func save(sut: LocalFeedLoader, models: [FeedImage]) -> LocalFeedLoader.SaveResult {
        var receivedResult: LocalFeedLoader.SaveResult = nil
        
        let exp = expectation(description: "Waiting for inser cache")
        sut.save(images: models) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
        
        return receivedResult
    }
    
    func expect(sut: LocalFeedLoader, with expectedImages: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Waiting for load cache")
        sut.load { result in
            switch result {
            case .success(let images):
                XCTAssertEqual(images, expectedImages, file: file, line: line)
            case .failure(let error):
                XCTFail("Should completed with success instead failure with \(error) error", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }
}
