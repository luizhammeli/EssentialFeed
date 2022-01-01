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
    
    func test_loadingIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeFeedLoader(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeFeedLoader(with: .failure(anyNSError()), at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func test_loadCompletion_() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(sut.numberOfRenderedFeedViews, 0)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoader(with: .success([makeFeedImage(location: nil, description: nil)]))
        XCTAssertEqual(sut.numberOfRenderedFeedViews, 1)
        
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoader(with: .success([makeFeedImage(location: nil, description: nil), makeFeedImage(location: nil, description: nil)]))
        XCTAssertEqual(sut.numberOfRenderedFeedViews, 2)
        
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoader(with: .failure(anyNSError()))
        XCTAssertEqual(sut.numberOfRenderedFeedViews, 2)
        
        XCTAssertNotNil(sut.tableView.cellForRow(at: IndexPath(row: 0, section: 0)))        
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
    
    func makeFeedImage(location: String?, description: String?) -> FeedImage {
        return FeedImage(id: UUID(), url: URL(string: "http://www.test.com")!, description: description, location: location)
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl!.isRefreshing
    }
    
    var numberOfRenderedFeedViews: Int {
        tableView.numberOfRows(inSection: feedImageSection)
    }
    
    var feedImageSection: Int { 0 }
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
        loadCompletionMessages[index](result)
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { (target as NSObject).perform(Selector($0)) }
        }
    }
}
