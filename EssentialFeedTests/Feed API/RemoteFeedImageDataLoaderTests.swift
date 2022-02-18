//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Luiz Diniz Hammerli on 17/02/22.
//

import Foundation
import XCTest
import EssentialFeed

final class RemoteFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURl() {
        let (_, clientSpy) = makeSUT()
        
        XCTAssertTrue(clientSpy.requestedURLS.isEmpty)
    }
    
    func test_load_requestDataFromCorrectURl() {
        let (sut , clientSpy) = makeSUT()
        let url = makeURL()
        
        sut.loadFeedImageData(from: url, completion: { _ in })
        
        XCTAssertEqual(clientSpy.requestedURLS, [url])
    }
    
    func test_loadTwice_requestsDataFromURlTwice() {
        let (sut , clientSpy) = makeSUT()
        let url = makeURL()
        let url2 = makeURL()
        
        sut.loadFeedImageData(from: url, completion: { _ in })
        sut.loadFeedImageData(from: url, completion: { _ in })
        
        XCTAssertEqual(clientSpy.requestedURLS, [url, url2])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, clientSpy) = makeSUT()
        
        expect(sut: sut, with: .failure(anyNSError())) {
            clientSpy.complete(with: anyNSError())
        }
    }
    
    func test_load_deliversErrorOnNon200StatusCodeResponse() {
        [400, 199, 500, 300].forEach { sample in
            let (sut, clientSpy) = makeSUT()
            expect(sut: sut, with: .failure(anyNSError())) {
                clientSpy.complete(with: sample, data: anyData())
            }
        }
    }
    
    func test_load_deliversErrorOn200HttpResponseWithInvalidData() {
        let (sut, clientSpy) = makeSUT()
        
        expect(sut: sut, with: .failure(anyNSError())) {
            clientSpy.complete(with: 200, data: Data())
        }
    }
    
    func test_load_deliversSuccessOn200HttpResponseWithValidData() {
        let (sut, clientSpy) = makeSUT()
        let data = anyData()
        
        expect(sut: sut, with: .success(data)) {
            clientSpy.complete(with: 200, data: data)
        }
    }
    
    func test_load_doesNotDeliversResultAfterSutHasBeenDealocatted() {
        let clientSpy = HttpClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: clientSpy)
        var results: [Swift.Result<Data, Error>] = []
        
        sut?.loadFeedImageData(from: makeURL()) { results.append($0) }
        
        sut = nil
        clientSpy.complete(with: NSError())
        XCTAssertTrue(results.isEmpty)
    }
    
    func test_cancelTask_shouldCancelTheRequestTask() {
        let (sut, clientSpy) = makeSUT()
        let url = makeURL()
        let task = sut.loadFeedImageData(from: url) { _ in }
        task.cancel()
        XCTAssertEqual(clientSpy.canceledURLS, [url])
    }
}

private extension RemoteFeedImageDataLoaderTests {
    func makeSUT() -> (RemoteFeedImageDataLoader, HttpClientSpy){
        let clientSpy = HttpClientSpy()
        let sut = RemoteFeedImageDataLoader(client: clientSpy)
        
        checkForMemoryLeaks(instance: clientSpy)
        checkForMemoryLeaks(instance: sut)
        
        return (sut, clientSpy)
    }
    
    func expect(sut: RemoteFeedImageDataLoader,
                with expectedResult: Swift.Result<Data, Error>,
                when action: @escaping () -> Void,
                file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Waiting for request")
        var receivedResult: Swift.Result<Data, Error>?
        
        sut.loadFeedImageData(from: makeURL(), completion: { result in
            receivedResult = result
            exp.fulfill()
        })
        
        action()
        wait(for: [exp], timeout: 1)
        
        switch (expectedResult, receivedResult) {
        case (.failure, .failure):
            break
        case (.success(let expectedData), .success(let receivedData)):
            XCTAssertEqual(expectedData, receivedData, file: file, line: line)
        default:
            XCTFail("Expected \(String(describing: expectedResult)) got \(String(describing: receivedResult)) instead", file: file, line: line)
        }
    }
}
