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
    let response: HTTPURLResponse?
    let data: Data?
}

final class URLSessionHttpClient: HttpClient {
    let urlSession: URLSession
    
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func get(from url: URL, completion: @escaping (HttpClientResult) -> Void) {
        urlSession.dataTask(with: url) { [weak self] data, response, error in
            guard self != nil else { return }
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse, let data = data else {
                completion(.failure(NSError(domain: "", code: 1, userInfo: nil)))
                return
            }
            
            completion(.success(data, response))
        }.resume()
    }
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
        let error = NSError(domain: "", code: 10, userInfo: [:])
        expect(makeSut(), with: .failure(error), url: makeURL(), response: nil, error: error, data: nil)
    }
    
    func test_get_failsOnAllNilValues() {
        expect(makeSut(), with: .failure(NSError(domain: "", code: 1, userInfo: nil)), url: makeURL(), response: nil, error: nil, data: nil)
    }
    
    func test_get_failsOnErrorAndReponseNilValues() {
        let data = "Test".data(using: .utf8)
        expect(makeSut(), with: .failure(NSError(domain: "", code: 1, userInfo: nil)), url: makeURL(), response: nil, error: nil, data: data)
    }
}

// MARK: Helpers
extension URLSessionHttpClientTests {
    private func makeSut(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHttpClient {
        let sut = URLSessionHttpClient()
        checkForMemoryLeaks(instance: sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: HttpClient, with expectedResult: HttpClientResult, url: URL, response: HTTPURLResponse?, error: Error?, data: Data?, file: StaticString = #filePath, line: UInt = #line) {
        URLProtocolStub.stub(url: url, response: response, error: error, data: data)
        let exp = expectation(description: "waiting")
        sut.get(from: makeURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.failure(let receivedError as NSError), .failure(let expectedError as NSError)):
                XCTAssertEqual(expectedError.code, receivedError.code, file: file, line: line)
            case (.success, .success):
                break
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
}

private class URLProtocolStub: URLProtocol {
    private static var stub: Stub?
    private static var requestObserver: ((URLRequest) -> Void)?
    
    static func stub(url: URL, response: HTTPURLResponse?, error: Error?, data: Data?) {
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
    
    override func stopLoading() {}
}
