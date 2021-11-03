//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Luiz Diniz Hammerli on 02/11/21.
//

import XCTest
@testable import EssentialFeed

final class RemoteFeedLoader: FeedLoader {
    let client: HttpClient
    let url: URL
    
    init(url: URL, client: HttpClient) {
        self.client = client
        self.url = url
    }
    
    func load(completion: @escaping (LoadFeedResult) -> Void) {
        client.get(from: url)
    }
}

protocol HttpClient {
    func get(from url: URL)
}

final class HttpClientSpy: HttpClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURl() {
        let (_, clientSpy) = makeSut()
        
        XCTAssertNil(clientSpy.requestedURL)
    }
    
    func test_load_requestDataFromURl() {
        let url = URL(string: "https://a-given-url.com")!
        let (feedLoader, clientSpy) = makeSut(url: url)
        
        feedLoader.load(completion: { _ in })
        
        XCTAssertEqual(clientSpy.requestedURL, url)
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
