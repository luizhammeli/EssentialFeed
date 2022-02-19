//
//  EssentialAppTests.swift
//  EssentialAppTests
//
//  Created by Luiz Hammerli on 19/02/22.
//

import XCTest
import EssentialApp
import EssentialFeed

final class FeedLoaderWithFallback: FeedLoader {
    let primary: FeedLoader
    let fallback: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure:
                self.fallback.load(completion: completion)
            }
        }
    }
}

final class FeedLoaderWithFallbackTests: XCTestCase {
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

private extension FeedLoaderWithFallbackTests {
    func makeSUT() -> (FeedLoaderWithFallback, RemoteFeedLoaderSpy, RemoteFeedLoaderSpy) {
        let primaryFeedLoader = RemoteFeedLoaderSpy()
        let fallbackFeedLoader = RemoteFeedLoaderSpy()
        let sut = FeedLoaderWithFallback(primary: primaryFeedLoader, fallback: fallbackFeedLoader)
        return (sut, primaryFeedLoader, fallbackFeedLoader)
    }
    
    func anyFeedImage() -> FeedImage {
        let url = URL(string: "https://test.com")!
        return FeedImage(id: UUID(), url: url, description: nil, location: nil)
    }
    
    func expect(sut: FeedLoaderWithFallback,
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

final class RemoteFeedLoaderSpy: FeedLoader {
    var completions: [(FeedLoader.Result) -> Void] = []
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completions.append(completion)
    }
    
    func complete(with result: FeedLoader.Result, at index: Int = 0) {
        completions[index](result)
    }
}
