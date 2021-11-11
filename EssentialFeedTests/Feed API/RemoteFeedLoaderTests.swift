//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Luiz Diniz Hammerli on 02/11/21.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURl() {
        let (_, clientSpy) = makeSut()
        
        XCTAssertTrue(clientSpy.requestedURLS.isEmpty)
    }
    
    func test_load_requestsDataFromURl() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, clientSpy) = makeSut(url: url)
        
        sut.load(completion: { _ in })
        
        XCTAssertEqual(clientSpy.requestedURLS, [url])
    }
    
    func test_loadTwice_requestsDataFromURlTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, clientSpy) = makeSut(url: url)
        
        sut.load(completion: { _ in })
        sut.load(completion: { _ in })
        
        XCTAssertEqual(clientSpy.requestedURLS, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, clientSpy) = makeSut()
        expect(sut: sut, toCompleteWith: failure(.connectivity)) {
            clientSpy.complete(with: NSError(domain: "", code: 0, userInfo: nil))
        }
    }
    
    func test_load_deliversErrorOnNon200HttpResponse() {
        let samples = [400, 199, 500, 300]
        samples.enumerated().forEach { index, code in
            let (sut, clientSpy) = makeSut()
            expect(sut: sut, toCompleteWith: failure(.invalid)) {
                clientSpy.complete(with: code, data: makeFeedJson(items: []))
            }
        }
    }
    
    func test_load_deliversErrorOn200HttpResponseWithInvalidData() {
        let (sut, clientSpy) = makeSut()
        expect(sut: sut, toCompleteWith: failure(.invalid)) {
            clientSpy.complete(with: 200, data: Data("invalid json".description.utf8))
        }
    }
    
    func test_load_deliversNoItemsOn200HttpResponseWithValidData() {
        let (sut, clientSpy) = makeSut()
        expect(sut: sut, toCompleteWith: .success([])) {
            clientSpy.complete(with: 200, data: makeFeedJson(items: []))
        }
    }
    
    func test_load_deliversItemsOn200HttpResponseWithValidData() {
        let (sut, clientSpy) = makeSut()
        let feedItem1 = makeFeedItem(id: UUID(), imageURL: makeURL())
        let feedItem2 = makeFeedItem(id: UUID(), imageURL: makeURL(), description: "Test Description", location: "Test Location")
        let jsonData = makeFeedJson(items: [feedItem1.1, feedItem2.1])
        
        expect(sut: sut, toCompleteWith: .success([feedItem1.0, feedItem2.0])) {
            clientSpy.complete(with: 200, data: jsonData)
        }
    }
    
    func test_load_doesNotDeliversResultAfterSutHasBeenDealocatted() {
        let clientSpy = HttpClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: makeURL(), client: clientSpy)
        var capturedErrors: [LoadFeedResult] = []
        let feedItem1 = makeFeedItem(id: UUID(), imageURL: makeURL())
        let jsonData = makeFeedJson(items: [feedItem1.1])
        
        sut?.load(completion: { capturedErrors.append($0) })
        sut = nil
        clientSpy.complete(with: 200, data: jsonData)
        
        XCTAssertTrue(capturedErrors.isEmpty)
    }
}

//MARK: - Helpers
private extension RemoteFeedLoaderTests {
    private func makeSut(url: URL = URL(string: "https://a-url.com")!) -> (RemoteFeedLoader, HttpClientSpy) {
        let clientSpy = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: clientSpy)
        checkForMemoryLeaks(instance: sut)
        checkForMemoryLeaks(instance: clientSpy)
        return (sut, clientSpy)
    }
    
    private func expect(sut: RemoteFeedLoader, toCompleteWith expectedResult: LoadFeedResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let expectation = expectation(description: "Waiting")
        sut.load(completion: { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(let receivedItems), .success(let expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case (.failure(let receivedError as RemoteFeedLoader.Error), .failure(let expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Assert error expect \(expectedResult) receive \(receivedResult)", file: file, line: line)
            }
            expectation.fulfill()
        })
        action()
        wait(for: [expectation], timeout: 1)
    }
    
    private func makeFeedItem(id: UUID, imageURL: URL, description: String? = nil, location: String? = nil) -> (FeedItem, [String: Any]){
        let feedItem = FeedItem(id: id, imageURL: imageURL, description: description, location: location)
        let feedItemJson = ["id": id.uuidString, "image": imageURL.description, "location": location, "description": description].reduce(into: [String: Any]()) { partialResult, item in
            if let value = item.value { partialResult[item.key] = value }
        }
        return (feedItem, feedItemJson)
    }
    
    private func makeFeedJson(items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
    }

    private func failure(_ error: RemoteFeedLoader.Error) -> LoadFeedResult {
        return .failure(error)
    }
}

final class HttpClientSpy: HttpClient {
    private var messages: [(url: URL, completions: (HttpClientResult) -> Void)] = []
    
    var requestedURLS: [URL] {
        return messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (HttpClientResult) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(with error: Error, index: Int = 0) {
        messages[index].completions(.failure(error))
    }
    
    func complete(with statusCode: Int, for index: Int = 0, data: Data = Data()) {
        let httpResponse = HTTPURLResponse(url: requestedURLS[index], statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        messages[index].completions(.success(data, httpResponse))
    }
}