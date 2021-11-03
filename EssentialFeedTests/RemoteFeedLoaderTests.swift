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
    var requestedURLS: [URL] = []
    
    func get(from url: URL) {
        requestedURLS.append(url)
    }
}
