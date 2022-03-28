//
//  FeedLoaderCompositeDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Luiz Hammerli on 22/02/22.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedLoaderCompositeDecoratorTests: XCTestCase, FeedLoaderFallbackTestCase {
    func test_init_deliversNoMessages() {
        let (_, spy) = makeSUT()
                
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
    func test_load_shouldCompleteWithCorrectData() {
        let (sut, spy) = makeSUT()
        let expectedResult: Result<[FeedImage], Error> = .success([anyFeedImage()])
                
        expect(sut: sut, with: expectedResult) {
            spy.complete(with: expectedResult)
        }
    }
    
    func test_load_shouldLoadAndSaveFeedDataWhenCompletionSucceeds() {
        let (sut, spy) = makeSUT()
        let expectedResult: Result<[FeedImage], Error> = .success([anyFeedImage()])
        
        expect(sut: sut, with: expectedResult) {
            spy.complete(with: expectedResult)
        }
                
        XCTAssertEqual(spy.messages, [.load, .save])
    }
    
    func test_load_shouldNotSaveFeedDataWhenCompletionFailure() {
        let (sut, spy) = makeSUT()
        let expectedResult: Result<[FeedImage], Error> = .failure(NSError(domain: "", code: 0, userInfo: nil))
        
        expect(sut: sut, with: expectedResult) {
            spy.complete(with: expectedResult)
        }
                
        XCTAssertEqual(spy.messages, [.load])
    }
}

private extension FeedLoaderCompositeDecoratorTests {
    func makeSUT() -> (FeedLoaderCompositeDecorator, RemoteFeedLoaderSpy) {
        let feedLoader = RemoteFeedLoaderSpy()
        let sut = FeedLoaderCompositeDecorator(feedLoader: feedLoader, feedCache: feedLoader)
        return (sut, feedLoader)
    }
}
