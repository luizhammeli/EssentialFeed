//
//  FeedLoaderCompositeDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Luiz Hammerli on 22/02/22.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedLoaderCompositeDecorator {
    let feedLoader: FeedLoader
    let feedCache: FeedCache
    
    init(feedLoader: FeedLoader, feedCache: FeedCache) {
        self.feedLoader = feedLoader
        self.feedCache = feedCache
    }
}

extension FeedLoaderCompositeDecorator: FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        feedLoader.load { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.saveFeedIgnoringCompletion(data: data)
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }            
        }
    }
    
    func saveFeedIgnoringCompletion(data: [FeedImage]) {
        feedCache.save(images: data, completion: { _ in })
    }
}

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
