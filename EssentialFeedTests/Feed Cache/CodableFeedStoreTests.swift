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
        
        let expectation = expectation(description: "Waiting for request")
        sut.retrive { result in
            switch result {
            case .empty: break
            default:
                XCTFail("Expected empty state got \(result) instead")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_retrive_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSut()
        
        let expectation = expectation(description: "Waiting for request")
        sut.retrive { firstResult in
            sut.retrive { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty): break
                default:
                    XCTFail("Expected empty state got \(secondResult) and \(firstResult) instead")
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_retriveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSut()
        
        let expectation = expectation(description: "Waiting for request")
        let items = anyUniqueFeedImages().localModels
        let expectedTimestamp = Date()
        let expectedResult: RetrievedCacheResult = .found(items, timestamp: expectedTimestamp)
        
        sut.insert(items: items, timestamp: expectedTimestamp) { error in
            XCTAssertNil(error)
            sut.retrive { receivedResult in
                switch (receivedResult, expectedResult) {
                case (.found(let receivedItems, let receivedDate), .found(let expectedItems, let expectedDate)):
                    XCTAssertEqual(receivedItems, expectedItems)
                    XCTAssertEqual(receivedDate, expectedDate)
                default:
                    XCTFail("Expected \(expectedResult) result got \(receivedResult) instead")
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_delete_delieversNilOnEmptyCache() {
        let sut = makeSut()
        var receivedError: Error?
        
        let exp = expectation(description: "Waiting for request")
        sut.deleteCachedItems { error in
            receivedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        XCTAssertNil(receivedError)
    }
    
    func test_deleteAfterInsert_delieversNilOnSuccessDeletion() {
        let sut = makeSut()
        var receivedError: Error?
        
        let exp = expectation(description: "Waiting for request")
        sut.insert(items: anyUniqueFeedImages().localModels, timestamp: Date()) { error in
            sut.deleteCachedItems { error in
                receivedError = error
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1)
        XCTAssertNil(receivedError)
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
}
