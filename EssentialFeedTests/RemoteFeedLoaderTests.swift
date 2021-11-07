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
        expect(sut: feedLoader, toCompleteWith: .connectivity) {
            clientSpy.complete(with: NSError(domain: "", code: 0, userInfo: nil))
        }
    }
    
    func test_load_deliversErrorOnNon200HttpResponse() {
        let samples = [400, 199, 500, 300]
        samples.enumerated().forEach { index, code in
            let (feedLoader, clientSpy) = makeSut()
            expect(sut: feedLoader, toCompleteWith: .invalid) {
                clientSpy.complete(with: code)
            }
        }
    }
    
    func test_load_deliversErrorOn200HttpResponseWithInvalidData() {
        let (feedLoader, clientSpy) = makeSut()
        expect(sut: feedLoader, toCompleteWith: .invalid) {
            clientSpy.complete(with: 200, data: Data("invalid json".description.utf8))
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
    
    private func expect(sut: RemoteFeedLoader, toCompleteWith error: RemoteFeedLoader.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedErrors: [RemoteFeedLoader.Error] = []
        sut.load(completion: { capturedErrors.append($0) })
        action()
        
        XCTAssertEqual(capturedErrors, [error], file: file, line: line)
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
