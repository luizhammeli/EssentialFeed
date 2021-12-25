//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Luiz Diniz Hammerli on 03/12/21.
//

import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase, FeedStoreSpecs {
    override func setUp() {
        super.setUp()
        deletesTestCache()
    }
    
    override func tearDown() {
        super.tearDown()
        deletesTestCache()
    }
    
    func test_retrive_deliversEmptyOnEmptyCache() {
        let sut = makeSut()
        expect(sut: sut, with: .empty)
    }
    
    func test_retrive_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSut()
        expect(sut: sut, toRetriveTwice: .empty)
    }
    
    func test_retrive_deliversFoundValueOnNonEmptyCache() {
        let sut = makeSut()
        let items = anyUniqueFeedImages().localModels
        let timestamp = Date()
    
        insert(sut: sut, items: items, timestamp: timestamp)
        expect(sut: sut, with: .found(items, timestamp: timestamp))
    }
    
    func test_retrive_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSut()
        let items = anyUniqueFeedImages().localModels
        let timestamp = Date()
        
        insert(sut: sut, items: items, timestamp: timestamp)
        expect(sut: sut, toRetriveTwice: .found(items, timestamp: timestamp))
    }
    
    func test_retrive_deliversErrorOnInvalidCache() {
        let url = testSpecificStoreURL()
        let sut = makeSut(storeURL: url)
        
        try! "Invalid Json".write(to: url, atomically: false, encoding: .utf8)
                        
        expect(sut: sut, with: .failure(anyNSError()))
    }
    
    func test_retrive_hasNoSideEffectsOnInvalidCache() {
        let url = testSpecificStoreURL()
        let sut = makeSut(storeURL: url)
        
        try! "Invalid Json".write(to: url, atomically: false, encoding: .utf8)
                        
        expect(sut: sut, with: .failure(anyNSError()))
        expect(sut: sut, with: .failure(anyNSError()))
    }
    
    func test_retrive_overridesPreviouslyInsertedCacheValue() {
        let url = testSpecificStoreURL()
        let sut = makeSut(storeURL: url)
        
        let latestedFeedCache = anyUniqueFeedImages()
        let latestedFeedCacheTimestamp = Date()
        
        let firstFeedError = insert(sut: sut, items: anyUniqueFeedImages().localModels, timestamp: Date())
        XCTAssertNil(firstFeedError, "Expected insert with success")
        
        let latestedFeedError = insert(sut: sut, items: latestedFeedCache.localModels, timestamp: latestedFeedCacheTimestamp)
        XCTAssertNil(latestedFeedError, "Expected insert with success")
                        
        expect(sut: sut, with: .found(latestedFeedCache.localModels, timestamp: latestedFeedCacheTimestamp))
    }
    
    func test_retrive_hasNoSideEffectsWhenOverridesPreviouslyInsertedCacheValue() {
        let sut = makeSut()
        let latestedFeedCache = anyUniqueFeedImages().localModels
        let latestedFeedCacheTimestamp = Date()
        
        insert(sut: sut, items: anyUniqueFeedImages().localModels, timestamp: Date())
        insert(sut: sut, items: latestedFeedCache, timestamp: latestedFeedCacheTimestamp)
        expect(sut: sut, toRetriveTwice: .found(latestedFeedCache, timestamp: latestedFeedCacheTimestamp))
    }
    
    func test_deleteCachedItems_deliversNoErrorWithEmptyCache() {
        let sut = makeSut()
                
        let deletionError = deleteCache(sut: sut)
        XCTAssertNil(deletionError, "Expected delete with success")
        
        expect(sut: sut, with: .empty)
    }
    
    func test_deleteCachedItems_hasNoSideEffectOnEmptyCache() {
        let sut = makeSut()
                
        let deletionError = deleteCache(sut: sut)
        XCTAssertNil(deletionError, "Expected delete with success")
                
        expect(sut: sut, toRetriveTwice: .empty)
    }
    
    func test_deleteCachedItems_deliversNoErrorWithNonEmptyCache() {
        let sut = makeSut()
        
        insert(sut: sut, items: anyUniqueFeedImages().localModels, timestamp: Date())
        let deletionError = deleteCache(sut: sut)
        XCTAssertNil(deletionError, "Expected delete with success")
        
        expect(sut: sut, with: .empty)
    }
    
    func test_deleteCachedItems_deliversErrorOnDeletionError() {
        let sut = makeSut(storeURL: cacheDirectory())

        insert(sut: sut, items: anyUniqueFeedImages().localModels, timestamp: Date())
        let deletionError = deleteCache(sut: sut)
        XCTAssertNotNil(deletionError, "Expected not nil error")
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSut(storeURL: cacheDirectory())
        var operations = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(items: anyUniqueFeedImages().localModels, timestamp: Date()) { _ in
            operations.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedItems { _ in
            operations.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(items: anyUniqueFeedImages().localModels, timestamp: Date()) { _ in
            operations.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 10.0)
        XCTAssertEqual(operations, [op1, op2, op3])
    }
}

//MARK: - Helpers
private extension CodableFeedStoreTests {
    private func makeSut(storeURL: URL? = nil) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cacheDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func deletesTestCache() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
