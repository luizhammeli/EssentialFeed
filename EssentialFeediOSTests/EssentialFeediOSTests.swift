//
//  EssentialFeediOSTests.swift
//  EssentialFeediOSTests
//
//  Created by Luiz Diniz Hammerli on 26/12/21.
//

import XCTest
import EssentialFeed
//import EssentialFeediOS

final class FeedViewController: UITableViewController {
    private var loader: FeedLoader? = nil
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
        loadFeed()
    }
    
    @objc private func loadFeed() {
        refreshControl?.beginRefreshing()
        loader?.load(completion: { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        })
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadFeed), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
}

final class EssentialFeediOSTests: XCTestCase {
    func test_viewDidLoad_shouldCallLoadAfterLoadedView() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.messagesCount, 1)
        XCTAssertTrue(sut.isShowingLoadingIndicator)
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
                
        XCTAssertTrue(sut.isShowingLoadingIndicator)
    }
    
    func test_viewDidLoad_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.complete()
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func test_userInitiatedFeedReload_loadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.messagesCount, 1)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.messagesCount, 2)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.messagesCount, 3)
    }
    
    func test_userInitiatedFeedReload_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.simulateUserInitiatedReload()

        XCTAssertTrue(sut.isShowingLoadingIndicator)
    }
    
    func test_userInitiatedFeedReload_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
                
        sut.simulateUserInitiatedReload()
        loader.complete()
        
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
}

// MARK: - Helpers
private extension EssentialFeediOSTests {
    func makeSUT() -> (FeedViewController, FeedLoaderSpy){
        let loader = FeedLoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        checkForMemoryLeaks(instance: sut)
        checkForMemoryLeaks(instance: loader)
        
        return (sut, loader)
    }
}

private extension FeedViewController {
    func simulateUserInitiatedReload() {
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
    
    func complete(with result: FeedLoader.Result = .success([]), at index: Int = 0) {
        loadCompletionMessages[0](result)
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { (target as NSObject).perform(Selector($0)) }
        }
    }
}
