//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Luiz Hammerli on 27/03/22.
//

import XCTest
import EssentialFeed

final class LocalFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURl() {
        let (_, storeSpy) = makeSUT()
        
        XCTAssertTrue(storeSpy.requestedData.isEmpty)
    }
    
    func test_loadFeedImageData_doesRequestDataFromURl() {
        let url = makeURL()
        let (sut, storeSpy) = makeSUT()
        
        sut.loadFeedImageData(from: url, completion: { _ in })
        XCTAssertEqual(storeSpy.requestedData, [.retrive(url: url)])
    }
    
    func test_loadFeedImageData_deliversErrorIfStoreCompletesWithError() {
        let url = makeURL()
        let (sut, storeSpy) = makeSUT()
        var receivedResult: (Result<Data, Error>)?
        let expectedResult: (Result<Data, Error>) = .failure(anyNSError())
        
        sut.loadFeedImageData(from: url, completion: { receivedResult = $0 })

        storeSpy.complete(with: expectedResult)
        
        switch (receivedResult, expectedResult) {
        case (.failure, .failure):
            break
        default:
            XCTFail("Expected \(expectedResult) result got \(String(describing: receivedResult)) instead")
        }
    }
    
    func test_loadFeedImageData_deliversSuccessWithCorrectDataIfStoreCompletesWithSuccess() {
        let url = makeURL()
        let (sut, storeSpy) = makeSUT()
        var receivedResult: (Result<Data, Error>)?
        let expectedResult: (Result<Data, Error>) = .success(anyData())
        
        sut.loadFeedImageData(from: url, completion: { receivedResult = $0 })

        storeSpy.complete(with: expectedResult)
        
        switch (receivedResult, expectedResult) {
        case (.success(let receveidData), .success(let expectedData)):
            XCTAssertEqual(receveidData, expectedData)
        default:
            XCTFail("Expected \(expectedResult) result got \(String(describing: receivedResult)) instead")
        }
    }
    
    func test_save_doesRequestDataFromURl() {
        let url = makeURL()
        let data = anyData()
        let (sut, storeSpy) = makeSUT()
        
        sut.save(with: url, data: data)
        XCTAssertEqual(storeSpy.requestedData, [.insert(url: url)])
    }
}

private extension LocalFeedImageDataLoaderTests {
    func makeSUT() -> (LocalFeedImageDataLoader, FeedImageStoreSpy) {
        let feedStore = FeedImageStoreSpy()
        return (LocalFeedImageDataLoader(feedStore: feedStore), feedStore)
    }
    
    final class FeedImageStoreSpy: FeedImageStore {
        enum Message: Equatable, Hashable {
            case retrive(url: URL)
            case insert(url: URL)
        }
        var requestedData: [Message] = []
        var completions: [(FeedImageStore.Result) -> Void] = []
        
        func retrive(url: URL, completion: @escaping (FeedImageStore.Result) -> Void) {
            requestedData.append(.retrive(url: url))
            completions.append(completion)
        }
                
        func insert(url: URL, data: Data) {
            requestedData.append(.insert(url: url))
        }
        
        func complete(with result: FeedImageStore.Result, at index: Int = 0) {
            completions[index](result)
        }
    }
}
