//
//  XCTestCase+URL.swift
//  EssentialFeedTests
//
//  Created by Luiz Diniz Hammerli on 10/11/21.
//

import Foundation
import EssentialFeed

func makeURL() -> URL {
    return URL(string: "https://a-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "", code: 10, userInfo: [:])
}

func anyData() -> Data {
    return Data("Test Case".utf8)
}

func anyHttpURLResponse() -> HTTPURLResponse {
    return HTTPURLResponse(url: makeURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
}

func anyURLResponse() -> URLResponse {
    return URLResponse(url: makeURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}

func anyUniqueFeedImage() -> FeedImage {
    return .init(id: UUID(), url: makeURL(), description: nil, location: nil)
}

func anyUniqueFeedImages() -> (models: [FeedImage], localModels: [LocalFeedItem]) {
    let models = [anyUniqueFeedImage(), anyUniqueFeedImage()]
    let localModels = models.map { LocalFeedItem(id: $0.id, imageURL: $0.url, description: $0.description, location: $0.location) }
    return (models, localModels)
}
