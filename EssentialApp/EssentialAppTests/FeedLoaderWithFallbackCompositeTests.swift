//
//  EssentialAppTests.swift
//  EssentialAppTests
//
//  Created by Luiz Hammerli on 19/02/22.
//

import XCTest
import EssentialApp
import EssentialFeed

final class FeedLoaderWithFallbackCompositeTests: XCTestCase, FeedLoaderFallbackTestCase {
    func test_init_shouldNotStartLoading() {
        let (_, primaryLoader, fallbackLoader) = makeSUT()
        
        XCTAssertTrue(primaryLoader.completions.isEmpty)
        XCTAssertTrue(fallbackLoader.completions.isEmpty)
    }
    
    func test_load_deliversFeedItemsIfPrimaryLoaderCompletesWithSuccess() {
        let (sut, primaryLoader, _) = makeSUT()
        let expectedResult: FeedLoader.Result = .success([anyFeedImage()])
        
        expect(sut: sut, with: expectedResult) {
            primaryLoader.complete(with: expectedResult)
        }
    }
    
    func test_load_deliversErrorIfPrimaryAndFallbackLoaderCompletesWithFailure() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        let expectedResult: FeedLoader.Result = .failure(NSError(domain: "", code: 0, userInfo: nil))
        
        expect(sut: sut, with: expectedResult) {
            primaryLoader.complete(with: expectedResult)
            fallbackLoader.complete(with: expectedResult)
        }
    }
    
    func test_load_deliversFeedItemsIfFallbackLoaderCompletesWithSuccess() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        let expectedResult: FeedLoader.Result = .success([anyFeedImage()])
        
        expect(sut: sut, with: expectedResult) {
            primaryLoader.complete(with: .failure(NSError(domain: "", code: 0, userInfo: nil)))
            fallbackLoader.complete(with: expectedResult)
        }
    }
}

private extension FeedLoaderWithFallbackCompositeTests {
    func makeSUT() -> (FeedLoaderWithFallbackComposite, RemoteFeedLoaderSpy, RemoteFeedLoaderSpy) {
        let primaryFeedLoader = RemoteFeedLoaderSpy()
        let fallbackFeedLoader = RemoteFeedLoaderSpy()
        let sut = FeedLoaderWithFallbackComposite(primary: primaryFeedLoader, fallback: fallbackFeedLoader)
        
        checkForMemoryLeaks(instance: primaryFeedLoader)
        checkForMemoryLeaks(instance: fallbackFeedLoader)
        checkForMemoryLeaks(instance: sut)
        
        return (sut, primaryFeedLoader, fallbackFeedLoader)
    }
}
