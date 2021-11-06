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
        var capturedErrors: [RemoteFeedLoader.Error] = []
        feedLoader.load(completion: { capturedErrors.append($0) })
        clientSpy.complete(with: NSError(domain: "", code: 0, userInfo: nil))
        
        XCTAssertEqual(capturedErrors, [RemoteFeedLoader.Error.connectivity])
    }
}

//MARK: - Helpers
private extension RemoteFeedLoaderTests {
    private func makeSut(url: URL = URL(string: "https://a-url.com")!) -> (RemoteFeedLoader, HttpClientSpy) {
        let clientSpy = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: clientSpy)
        return (sut, clientSpy)
    }
}

final class HttpClientSpy: HttpClient {
    private var messages: (requestedURLS: [URL], completions: [(Error?) -> Void]) = ([], [])
    
    var requestedURLS: [URL] {
        return messages.requestedURLS
    }
    
    func get(from url: URL, completion: @escaping (Error?) -> Void) {
        messages.requestedURLS.append(url)
        messages.completions.append(completion)
    }
    
    func complete(with error: Error, index: Int = 0) {
        messages.completions[0](error)
    }
}
