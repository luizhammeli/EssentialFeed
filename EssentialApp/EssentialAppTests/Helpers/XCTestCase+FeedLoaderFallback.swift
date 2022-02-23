//
//  XCTestCase+FeedLoaderFallback.swift
//  EssentialAppTests
//
//  Created by Luiz Hammerli on 20/02/22.
//

import EssentialFeed
import EssentialApp
import XCTest

protocol FeedLoaderFallbackTestCase: XCTestCase {}

extension FeedLoaderFallbackTestCase {
    func expect(sut: FeedLoaderWithFallbackComposite,
                with expectedResult: FeedLoader.Result,
                when action: () -> Void,
                file: StaticString = #filePath,
                line: UInt = #line) {
        var receveidResult: FeedLoader.Result?
        
        sut.load { receveidResult = $0 }
        action()
        
        switch (receveidResult, expectedResult) {
        case (.success(let receivedItems), .success(let expecteditems)):
            XCTAssertEqual(receivedItems, expecteditems, file: file, line: line)
        case (.failure, .failure):
            break
        default:
            XCTFail("Expected \(expectedResult) got \(String(describing: receveidResult)) instead", file: file, line: line)
        }
    }

}
