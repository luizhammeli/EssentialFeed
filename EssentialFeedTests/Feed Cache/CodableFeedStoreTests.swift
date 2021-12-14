//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Luiz Diniz Hammerli on 03/12/21.
//

import XCTest
import EssentialFeed

final class CodableFeedStore {
    private struct Cache: Codable {
        let items: [CodableFeedItem]
        let timestamp: Date
        
        func localItems() -> [LocalFeedItem] {
            return items.map { $0.toLocal() }
        }
    }
    
    private struct CodableFeedItem: Codable {
        public let id: UUID
        public let imageURL: URL
        public let description: String?
        public let location: String?
        
        init(_ localFeedImage: LocalFeedItem) {
            self.id = localFeedImage.id
            self.imageURL = localFeedImage.imageURL
            self.description = localFeedImage.description
            self.location = localFeedImage.location
        }
        
        func toLocal() -> LocalFeedItem {
            return LocalFeedItem(id: id, imageURL: imageURL, description: description, location: location)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func deleteCachedItems(completion: @escaping FeedStore.DeletionCompletion) {
        guard (try? Data(contentsOf: storeURL)) != nil else { return completion(nil) }
        
        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch(let error) {
            completion(error)
        }
    }
    
    func insert(items: [LocalFeedItem], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let cache = Cache(items: items.map { CodableFeedItem.init($0) }, timestamp: timestamp)
        do {
            let data = try JSONEncoder().encode(cache)
            try data.write(to: storeURL)
            completion(nil)
        } catch {
            completion(NSError(domain: "", code: 10, userInfo: nil))
        }
    }
    
    func retrive(completion: @escaping FeedStore.RetreiveCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else { return completion(.empty) }
        
        do {
            let cache = try JSONDecoder().decode(Cache.self, from: data)
            completion(.found(cache.localItems(), timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
    }
}

final class CodableFeedStoreTests: XCTestCase {
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
        
        let previousFeedError = insert(sut: sut, items: anyUniqueFeedImages().localModels, timestamp: Date())
        XCTAssertNil(previousFeedError)
        
        let latestedFeedError = insert(sut: sut, items: latestedFeedCache.localModels, timestamp: latestedFeedCacheTimestamp)
        XCTAssertNil(latestedFeedError)
                        
        expect(sut: sut, with: .found(latestedFeedCache.localModels, timestamp: latestedFeedCacheTimestamp))
    }
    
    func test_retrive_hasNoSideEffectsWhenOverridesPreviouslyInsertedCacheValue() {
        let sut = makeSut()
        let secondInserteditems = anyUniqueFeedImages().localModels
        let secondsInsertedTimestamp = Date()
        
        insert(sut: sut, items: anyUniqueFeedImages().localModels, timestamp: Date())
        insert(sut: sut, items: secondInserteditems, timestamp: secondsInsertedTimestamp)
        expect(sut: sut, toRetriveTwice: .found(secondInserteditems, timestamp: secondsInsertedTimestamp))
    }
}

//MARK: - Helpers
private extension CodableFeedStoreTests {
    private func makeSut(storeURL: URL? = nil) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func deletesTestCache() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func expect(sut: CodableFeedStore, toRetriveTwice result: RetrievedCacheResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut: sut, with: result)
        expect(sut: sut, with: result)
    }
    
    private func expect(sut: CodableFeedStore, with expectedResult: RetrievedCacheResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Waiting for request")
        
        sut.retrive { receivedResult in
            switch (receivedResult, expectedResult) {
                
            case (.found(let receivedItems, let receivedDate), .found(let expectedItems, let expectedDate)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                XCTAssertEqual(receivedDate, expectedDate, file: file, line: line)
                
            case (.empty, .empty), (.failure, .failure): break
                
            default:
                XCTFail("Expected \(expectedResult) result got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    @discardableResult
    private func insert(sut: CodableFeedStore, items: [LocalFeedItem], timestamp: Date) -> Error? {
        let expectation = expectation(description: "Waiting for request")
        var expectedError: Error?
        sut.insert(items: items, timestamp: timestamp) { error in
            XCTAssertNil(error)
            expectedError = error
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        return expectedError
    }
}
