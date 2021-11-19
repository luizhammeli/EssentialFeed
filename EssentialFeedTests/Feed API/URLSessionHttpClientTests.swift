//
//  URLSessionHttpClientTests.swift
//  EssentialFeedTests
//
//  Created by Luiz Diniz Hammerli on 10/11/21.
//

import Foundation
import XCTest
import EssentialFeed

private struct Stub {
    let error: Error?
    let response: URLResponse?
    let data: Data?
}

final class URLSessionHttpClientTests: XCTestCase {    
    override class func setUp() {
        URLProtocolStub.startIntercepting()
    }
    
    override class func tearDown() {
        URLProtocolStub.stopIntercepting()
    }
    
    func test_get_shouldRequestWithCorrectUrl() {
        let url = makeURL()
        let sut = makeSut()

        let exp = expectation(description: "waiting")
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        sut.get(from: url) { _ in }
        wait(for: [exp], timeout: 1)
    }
    
    func test_get_failsOnRequestError() {
        XCTAssertNotNil(errorValueFor(response: nil, error: anyNSError(), data: nil))
    }
    
    func test_get_failsOnAllInvalidCases() {
        XCTAssertNotNil(errorValueFor(response: nil, error: nil, data: nil))
        XCTAssertNotNil(errorValueFor(response: anyURLResponse(), error: nil, data: nil))
        XCTAssertNotNil(errorValueFor(response: nil, error: nil, data: anyData()))
        XCTAssertNotNil(errorValueFor(response: anyHttpURLResponse(), error: anyNSError(), data: nil))
        XCTAssertNotNil(errorValueFor(response: anyURLResponse(), error: anyNSError(), data: nil))
        XCTAssertNotNil(errorValueFor(response: anyURLResponse(), error: nil, data: anyData()))
        XCTAssertNotNil(errorValueFor(response: nil, error: anyNSError(), data: anyData()))
        XCTAssertNotNil(errorValueFor(response: anyHttpURLResponse(), error: anyNSError(), data: anyData()))
        XCTAssertNotNil(errorValueFor(response: anyURLResponse(), error: anyNSError(), data: anyData()))
    }
    
    func test_get_succeedsWithReponseAndData() {
        let response = anyHttpURLResponse()
        let data = anyData()
        let result = successValueFor(response: response, error: nil, data: data)
        XCTAssertEqual(result?.0, data)
        XCTAssertEqual(result?.1.statusCode, response.statusCode)
        XCTAssertEqual(result?.1.url, response.url)
    }
    
    func test_get_succeedsWithReponseAndEmptyData() {
        let response = anyHttpURLResponse()
        let result = successValueFor(response: response, error: nil, data: Data())
        XCTAssertEqual(result?.0, Data())
        XCTAssertEqual(result?.1.statusCode, response.statusCode)
        XCTAssertEqual(result?.1.url, response.url)
    }
}

// MARK: Helpers
extension URLSessionHttpClientTests {
    private func makeSut(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHttpClient {
        let sut = URLSessionHttpClient()
        checkForMemoryLeaks(instance: sut, file: file, line: line)
        return sut
    }
    
    private func errorValueFor(response: URLResponse?, error: Error?, data: Data?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultValueFor(response: response, error: error, data: data)
        switch result {
        case .failure(let error):
            return error
        default:
            XCTFail("Expected failure got \(String(describing: result)) instead", file: file, line: line)
        }
        return nil
    }
    
    private func successValueFor(response: URLResponse?, error: Error?, data: Data?, file: StaticString = #filePath, line: UInt = #line) -> (Data, HTTPURLResponse)? {
        let result = resultValueFor(response: response, error: error, data: data)
        switch result {
        case let .success(data, response):
            return (data, response)
        default:
            XCTFail("Expected success got \(String(describing: result)) instead", file: file, line: line)
        }
        return nil
    }
    
    private func resultValueFor(response: URLResponse?, error: Error?, data: Data?) -> HttpClientResult? {
        URLProtocolStub.stub(url: makeURL(), response: response, error: error, data: data)
        let sut = makeSut()
        let exp = expectation(description: "waiting")
        var receivedResult: HttpClientResult?
        sut.get(from: makeURL()) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return receivedResult
    }
}

private class URLProtocolStub: URLProtocol {
    private static var stub: Stub?
    private static var requestObserver: ((URLRequest) -> Void)?
    
    static func stub(url: URL, response: URLResponse?, error: Error?, data: Data?) {
        URLProtocolStub.stub = Stub(error: error, response: response, data: data)
    }
    
    static func startIntercepting() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopIntercepting() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }
    
    static func observeRequest(_ observer: @escaping (URLRequest) -> Void) {
        requestObserver = observer
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        URLProtocolStub.requestObserver?(request)
        
        if let response = URLProtocolStub.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        if let data = URLProtocolStub.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        URLProtocolStub.requestObserver = nil
    }
}
