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
        let (feedLoader, clientSpy) = makeSut(url: url)
        
        feedLoader.load(completion: { _ in })
        
        XCTAssertEqual(clientSpy.requestedURLS, [url])
    }
    
    func test_loadTwice_requestsDataFromURlTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (feedLoader, clientSpy) = makeSut(url: url)
        
        feedLoader.load(completion: { _ in })
        feedLoader.load(completion: { _ in })
        
        XCTAssertEqual(clientSpy.requestedURLS, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (feedLoader, clientSpy) = makeSut()
        expect(sut: feedLoader, toCompleteWith: .failure(RemoteFeedLoader.Error.connectivity)) {
            clientSpy.complete(with: NSError(domain: "", code: 0, userInfo: nil))
        }
    }
    
    func test_load_deliversErrorOnNon200HttpResponse() {
        let samples = [400, 199, 500, 300]
        samples.enumerated().forEach { index, code in
            let (feedLoader, clientSpy) = makeSut()
            expect(sut: feedLoader, toCompleteWith: .failure(.invalid)) {
                clientSpy.complete(with: code, data: makeFeedJson(items: []))
            }
        }
    }
    
    func test_load_deliversErrorOn200HttpResponseWithInvalidData() {
        let (feedLoader, clientSpy) = makeSut()
        expect(sut: feedLoader, toCompleteWith: .failure(.invalid)) {
            clientSpy.complete(with: 200, data: Data("invalid json".description.utf8))
        }
    }
    
    func test_load_deliversNoItemsOn200HttpResponseWithValidData() {
        let (feedLoader, clientSpy) = makeSut()
        expect(sut: feedLoader, toCompleteWith: .success([])) {
            clientSpy.complete(with: 200, data: makeFeedJson(items: []))
        }
    }
    
    func test_load_deliversItemsOn200HttpResponseWithValidData() {
        let (feedLoader, clientSpy) = makeSut()
        let feedItem1 = makeFeedItem(id: UUID(), imageURL: makeURL(), description: nil, location: nil)
        let feedItem2 = makeFeedItem(id: UUID(), imageURL: makeURL(), description: "Test Description", location: "Test Location")
        let jsonData = makeFeedJson(items: [feedItem1.1, feedItem2.1])

        expect(sut: feedLoader, toCompleteWith: .success([feedItem1.0, feedItem2.0])) {
            clientSpy.complete(with: 200, data: jsonData)
        }
    }
}

//MARK: - Helpers
private extension RemoteFeedLoaderTests {
    private func makeSut(url: URL = URL(string: "https://a-url.com")!) -> (RemoteFeedLoader, HttpClientSpy) {
        let clientSpy = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: clientSpy)
        return (sut, clientSpy)
    }
    
    private func expect(sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedErrors: [RemoteFeedLoader.Result] = []
        sut.load(completion: { capturedErrors.append($0) })
        action()
        
        XCTAssertEqual(capturedErrors, [result], file: file, line: line)
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
    
    private func makeURL() -> URL {
        return URL(string: "https://a-url.com")!
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
        messages[index].completions(.error(error))
    }
    
    func complete(with statusCode: Int, for index: Int = 0, data: Data = Data()) {
        let httpResponse = HTTPURLResponse(url: requestedURLS[index], statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        messages[index].completions(.success(data, httpResponse))
    }
}
