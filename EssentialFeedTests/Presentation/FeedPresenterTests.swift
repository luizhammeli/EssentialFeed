//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Luiz Hammerli on 13/02/22.
//

import XCTest
import EssentialFeed

final class FeedPresenterTests: XCTestCase {
    func test_init_doesNotSendAnyMessageToView() {
        let (_, viewSpy) = makeSUT()
        XCTAssertTrue(viewSpy.messages.isEmpty)
    }
    
    func test_didStartLoadingFeed_shouldSendIsLoadingViewMessage() {
        let (sut, viewSpy) = makeSUT()
        
        sut.didStartLoadingFeed()
        XCTAssertEqual(viewSpy.messages, [.display(isLoading: true)])
    }
    
    func test_didLoadFeedWithError_shouldSendIsLoadingViewMessage() {
        let (sut, viewSpy) = makeSUT()
        
        sut.didLoadFeedWithError()
        XCTAssertEqual(viewSpy.messages, [.display(isLoading: false)])
    }
    
    func test_didFinishLoadingFeed_shouldStopLoadingAndDisplayReturnFeedItem() {
        let (sut, viewSpy) = makeSUT()
        
        let feedImage = anyUniqueFeedImage()
        
        sut.didFinishLoadingFeed(feedItem: [feedImage])
        XCTAssertEqual(viewSpy.messages, [.display(isLoading: false), .display(feedImages: [feedImage])])
    }
    
    func test_title_shouldReturnCorrectTitle() {
        XCTAssertEqual(FeedViewPresenter.title, getLocalizedString())
    }
}

private extension FeedPresenterTests {
    func makeSUT() -> (FeedViewPresenter, FeedViewSpy) {
        let viewSpy = FeedViewSpy()
        let sut = FeedViewPresenter(loadingView: viewSpy, feedView: viewSpy)
        return (sut, viewSpy)
    }
    
    func getLocalizedString(for key: String = "FEED_VIEW_TITLE") -> String {
        return NSLocalizedString(key,
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedViewPresenter.self), comment: "")
    }
}

final class FeedViewSpy: FeedLoadingView, FeedView {
    enum Messages: Equatable, Hashable {
        case display(isLoading: Bool)
        case display(feedImages: [FeedImage])
    }
    
    var messages = Set<Messages>()
    
    func display(viewModel: FeedLoadingViewModel) {
        messages.insert(.display(isLoading: viewModel.isLoading))
    }
    
    func display(viewModel: FeedViewModel) {
        messages.insert(.display(feedImages: viewModel.feedItem))
    }
}
