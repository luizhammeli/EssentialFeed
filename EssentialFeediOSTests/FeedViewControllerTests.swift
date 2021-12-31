//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Luiz Diniz Hammerli on 26/12/21.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {
    func test_loadActions_loadsFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.messagesCount, 1)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.messagesCount, 2)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.messagesCount, 3)
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
                
        XCTAssertTrue(sut.isShowingLoadingIndicator)
    }
    
    func test_loadingIndicator_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeFeedLoader(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeFeedLoader(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
}

// MARK: - Helpers
private extension FeedViewControllerTests {
    func makeSUT() -> (FeedViewController, FeedLoaderSpy){
        let loader = FeedLoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        checkForMemoryLeaks(instance: sut)
        checkForMemoryLeaks(instance: loader)
        
        return (sut, loader)
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl!.isRefreshing
    }
}

private class FeedLoaderSpy: FeedLoader {
    private var loadCompletionMessages = [(FeedLoader.Result) -> Void]()
    
    var messagesCount: Int {
        loadCompletionMessages.count
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        loadCompletionMessages.append(completion)
    }
    
    func completeFeedLoader(with result: FeedLoader.Result = .success([]), at index: Int = 0) {
        loadCompletionMessages[index ](result)
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { (target as NSObject).perform(Selector($0)) }
        }
    }
}
