//
//  XCTestCase+URL.swift
//  EssentialFeedTests
//
//  Created by Luiz Diniz Hammerli on 10/11/21.
//

import Foundation

func makeURL() -> URL {
    return URL(string: "https://a-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "", code: 10, userInfo: [:])
}

func anyData(value: String = "Test Case") -> Data {
    return Data(value.utf8)
}

func anyHttpURLResponse() -> HTTPURLResponse {
    return HTTPURLResponse(url: makeURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
}

func anyURLResponse() -> URLResponse {
    return URLResponse(url: makeURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}
