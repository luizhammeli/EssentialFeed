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
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        guard let cache = try? JSONDecoder().decode(Cache.self, from: data) else { return completion(.failure(NSError(domain: "", code: 10, userInfo: nil))) }
        completion(.found(cache.localItems(), timestamp: cache.timestamp))
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
        let sut = makeSut()
        
        try! "Invalid Json".write(to: storeURL(), atomically: false, encoding: .utf8)
                        
        expect(sut: sut, with: .failure(anyNSError()))
    }
}

//MARK: - Helpers
private extension CodableFeedStoreTests {
    private func makeSut() -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL())
        return sut
    }
    
    private func storeURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func deletesTestCache() {
        try? FileManager.default.removeItem(at: storeURL())
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
                
            case (.empty, .empty): break
                
            case (.failure, .failure): break
                
            default:
                XCTFail("Expected \(expectedResult) result got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func insert(sut: CodableFeedStore, items: [LocalFeedItem], timestamp: Date) {
        let expectation = expectation(description: "Waiting for request")
        sut.insert(items: items, timestamp: timestamp) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}
