//
//  FeedUIIntegrationTests.swift
//  EssentialFeediOSTests
//
//  Created by Luiz Diniz Hammerli on 26/12/21.
//

import XCTest
import EssentialFeed
@testable import EssentialFeediOS

final class FeedUIIntegrationTests: XCTestCase {
    func test_loadActions_showsTheCorrectTitle() {
        let (sut, _) = makeSUT()
                       
        XCTAssertEqual(sut.title, localized(key: "FEED_VIEW_TITLE"))
    }
        
    func test_loadActions_loadsFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCompletionMessagesCount, 1)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCompletionMessagesCount, 2)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCompletionMessagesCount, 3)
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
        assertThat(sut: sut, isRendering: [image0])
                
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoader(with: .success([image0, image1, image2]), at: 1)
        assertThat(sut: sut, isRendering: [image0, image1, image2])
    }
    
    func test_loadCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let (sut, loader) = makeSUT()
        
        let image0 = makeFeedImage(location: "Location 1", description: "Description 1")
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoader(with: .success([image0]))
        assertThat(sut: sut, isRendering: [image0])
                
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoader(with: .failure(anyNSError()), at: 1)
        assertThat(sut: sut, isRendering: [image0])
    }
    
    func test_loadImageData_loadsImageWhenIsVisible() {
        let (sut, loader) = makeSUT()
        let url0 = URL(string: "http://image0.com")!
        let url1 = URL(string: "http://image1.com")!
        
        let image0 = makeFeedImage(location: nil, description: nil, url: url0)
        let image1 = makeFeedImage(location: nil, description: nil, url: url1)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoader(with: .success([image0, image1]))
        sut.feedImageView(at: 0)
        
        XCTAssertEqual(loader.loadImagesURLs, [url0])
        sut.feedImageView(at: 1)
        
        XCTAssertEqual(loader.loadImagesURLs, [url0, url1])
    }
    
    func test_loadImageData_cancelsImageLoadingWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        
        let image0 = makeFeedImage(location: nil, description: nil, url: URL(string: "http://image0.com")!)
        let image1 = makeFeedImage(location: nil, description: nil, url: URL(string: "http://image1.com")!)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoader(with: .success([image0, image1]))
        XCTAssertEqual(loader.canceledTasks, [])
        
        sut.simulateImageNotVisible(at: 0)
        XCTAssertEqual(loader.canceledTasks, [image0.url])
                
        sut.simulateImageNotVisible(at: 1)
        XCTAssertEqual(loader.canceledTasks, [image0.url, image1.url])
    }
    
    func test_feedImageLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        
        let image0 = makeFeedImage(location: nil, description: nil, url: URL(string: "http://image0.com")!)
        let image1 = makeFeedImage(location: nil, description: nil, url: URL(string: "http://image1.com")!)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoader(with: .success([image0, image1]))
        
        let view = sut.simulateImageViewVisible(at: 0)
        XCTAssertTrue(view!.isShowingLoadingIndicator)
        
        loader.completeImageLoading(with: .success(anyData()))
        XCTAssertFalse(view!.isShowingLoadingIndicator)
        
        let view2 = sut.simulateImageViewVisible(at: 1)
        XCTAssertTrue(view2!.isShowingLoadingIndicator)
        
        loader.completeImageLoading(with: .failure(anyNSError()), at: 1)
        XCTAssertFalse(view2!.isShowingLoadingIndicator)
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        let image0 = makeFeedImage(location: nil, description: nil, url: URL(string: "http://image0.com")!)
        let image1 = makeFeedImage(location: nil, description: nil, url: URL(string: "http://image1.com")!)
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoader(with: .success([image0, image1]))
        
        let view = sut.simulateImageViewVisible(at: 0)
        loader.completeImageLoading(with: .success(imageData0), at: 0)
        XCTAssertEqual(imageData0, view?.feedImageData)
        
        let view1 = sut.simulateImageViewVisible(at: 1)
        loader.completeImageLoading(with: .success(imageData1), at: 1)
        XCTAssertEqual(imageData1, view1?.feedImageData)
    }
    
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoader(with: .success([makeFeedImage(), makeFeedImage()]))
        
        let view = sut.simulateImageViewVisible(at: 0)
        let view1 = sut.simulateImageViewVisible(at: 1)
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: .success(imageData0), at: 0)
        XCTAssertFalse(view!.isShowingRetryButton)
        XCTAssertFalse(view1!.isShowingRetryButton)
        
        loader.completeImageLoading(with: .failure(anyNSError()), at: 1)
        XCTAssertFalse(view!.isShowingRetryButton)
        XCTAssertTrue(view1!.isShowingRetryButton)
    }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidLoadedImageData() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoader(with: .success([makeFeedImage(), makeFeedImage()]))
        
        let view = sut.simulateImageViewVisible(at: 0)
        let view1 = sut.simulateImageViewVisible(at: 1)
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        XCTAssertFalse(view!.isShowingRetryButton)
        XCTAssertFalse(view1!.isShowingRetryButton)
        
        loader.completeImageLoading(with: .success(imageData0), at: 0)
        loader.completeImageLoading(with: .success(anyData()), at: 1)
        XCTAssertFalse(view!.isShowingRetryButton)
        XCTAssertTrue(view1!.isShowingRetryButton)
    }
    
    func test_feedImageViewRetryButton_retriesImageLoad() {
        let (sut, loader) = makeSUT()
        
        let image0 = makeFeedImage(location: nil, description: nil, url: URL(string: "http://image0.com")!)
        let image1 = makeFeedImage(location: nil, description: nil, url: URL(string: "http://image1.com")!)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoader(with: .success([image0, image1]))
        
        let view = sut.simulateImageViewVisible(at: 0)
        let view1 = sut.simulateImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadImagesURLs, [image0.url, image1.url])
                
        loader.completeImageLoading(with: .failure(anyNSError()), at: 0)
        loader.completeImageLoading(with: .failure(anyNSError()), at: 1)
        XCTAssertEqual(loader.loadImagesURLs, [image0.url, image1.url])
        
        view?.simulateRetryAction()
        XCTAssertEqual(loader.loadImagesURLs, [image0.url, image1.url, image0.url])
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadImagesURLs, [image0.url, image1.url, image0.url, image1.url])
    }
    
    func test_() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoader(with: .success([makeFeedImage()]))
        
        sut.simulateImageViewVisible(at: 0)
        let view = sut.simulateImageNotVisible(at: 0)
                
        loader.completeImageLoading(with: .success(anyImageData()), at: 0)
        XCTAssertNil(view?.feedImageView.image)
    }
}

// MARK: - Helpers
private extension FeedUIIntegrationTests {
    func makeSUT() -> (FeedViewController, FeedLoaderSpy){
        let loader = FeedLoaderSpy()
        let sut = FeedUIComposer.feedCompose(with: loader, imageLoader: loader)
        
        checkForMemoryLeaks(instance: sut)
        checkForMemoryLeaks(instance: loader)
        
        return (sut, loader)
    }
    
    func makeFeedImage(location: String? = nil, description: String? = nil, url: URL = URL(string: "http://www.test.com")!) -> FeedImage {
        return FeedImage(id: UUID(), url: url, description: description, location: location)
    }
    
    func assertThat(sut: FeedViewController, isRendering feedImage: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedFeedViews, feedImage.count, file: file, line: line)
        feedImage.enumerated().forEach { assertThat(sut: sut, hasViewConfiguredFor: $1, at: $0, file: file, line: line) }
    }
    
    private func assertThat(sut: FeedViewController, hasViewConfiguredFor feedImage: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view else {
            XCTFail("Expected \(FeedImageCell.self) instance, instead got \(String(describing: view)) instance")
            return
        }
        
        let shouldLocationBeVisible = !(feedImage.location == nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected location view hidden", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionText, feedImage.description, "Expected \(String(describing: feedImage.description)) description at \(index) index", file: file, line: line)
        
        XCTAssertEqual(cell.locationText, feedImage.location, "Expected \(String(describing: feedImage.location)) location at \(index) index", file: file, line: line)
    }
    
    private func anyImageData() -> Data {
        return UIImage.make(withColor: .blue).pngData()!
    }
    
    private func localized(key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedViewPresenter.self)
        let localizedTitle = bundle.localizedString(forKey: key, value: nil, table: "Feed")
        
        if localizedTitle == key {
            XCTFail("Missing localized string for key: \(key)", file: file, line: line)
        }
        
        return localizedTitle
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateImageViewVisible(at index: Int) -> FeedImageCell? {
        feedImageView(at: index)
    }
    
    @discardableResult
    func simulateImageNotVisible(at index: Int) -> FeedImageCell? {
        let indexPath = IndexPath(row: index, section: 0)
        let view = simulateImageViewVisible(at: index)!
        tableView(tableView, didEndDisplaying: view, forRowAt: indexPath)
        return view
    }
    
    @discardableResult
    func feedImageView(at index: Int) -> FeedImageCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: index, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath) as? FeedImageCell
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
    
    var isShowingLoadingIndicator: Bool {
        feedImageContainer.isShimmering
    }
    
    var feedImageData: Data? {
        return feedImageView.image?.pngData()
    }
    
    var isShowingRetryButton: Bool {
        return !retryButton.isHidden
    }
    
    func simulateRetryAction() {
        retryButton.simulateTap()
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { (target as NSObject).perform(Selector($0)) }
        }
    }
}

private extension UIButton {
     func simulateTap() {
         allTargets.forEach { target in
             actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                 (target as NSObject).perform(Selector($0))
             }
         }
     }
 }

private extension UIImage {
     static func make(withColor color: UIColor) -> UIImage {
         let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
         UIGraphicsBeginImageContext(rect.size)
         let context = UIGraphicsGetCurrentContext()!
         context.setFillColor(color.cgColor)
         context.fill(rect)
         let img = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
         return img!
     }
 }
