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
    
    func test_loadCompletion_rendersSuccessfullyLoadedFeed() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(sut.numberOfRenderedFeedViews, 0)
        
        let image0 = makeFeedImage(location: "Location 1", description: "Description 1")
        let image1 = makeFeedImage(location: nil, description: nil)
        let image2 = makeFeedImage(location: "Location 2", description: "Description 2")
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoader(with: .success([image0]))
        assert(sut: sut, with: [image0])
        
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoader(with: .success([image0, image1, image2]))
        assert(sut: sut, with: [image0, image1, image2])
        
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoader(with: .failure(anyNSError()))
        assert(sut: sut, with: [image0, image1, image2])
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
    
    func assert(sut: FeedViewController, with feedImage: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedFeedViews, feedImage.count, file: file, line: line)
        feedImage.enumerated().forEach { assertThat(sut: sut, hasViewConfiguredFor: $1, at: $0, file: file, line: line) }
    }
    
    private func assertThat(sut: FeedViewController, hasViewConfiguredFor feedImage: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            XCTFail("Expected \(FeedImageCell.self) instance, instead got \(String(describing: view)) instance")
            return
        }
        
        let shouldLocationBeVisible = !(feedImage.location == nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected location view hidden", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionText, feedImage.description, "Expected \(String(describing: feedImage.description)) description at \(index) index", file: file, line: line)
        
        XCTAssertEqual(cell.locationText, feedImage.location, "Expected \(String(describing: feedImage.location)) location at \(index) index", file: file, line: line)
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func feedImageView(at index: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: index, section: feedImageSection)
        return (ds?.tableView(tableView, cellForRowAt: indexPath))
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl!.isRefreshing
    }
    
    var numberOfRenderedFeedViews: Int {
        tableView.numberOfRows(inSection: feedImageSection)
    }
    
    var feedImageSection: Int { 0 }
}

private extension FeedImageCell {
    var isShowingLocation: Bool {
        !locationLabel.isHidden
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var locationText: String? {
        locationLabel.text
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
