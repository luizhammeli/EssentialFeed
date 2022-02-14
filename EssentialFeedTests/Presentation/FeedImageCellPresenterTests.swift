//
//  FeedImageCellPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Luiz Hammerli on 13/02/22.
//

import XCTest
import EssentialFeed

final class FeedImageCellPresenterTests: XCTestCase {
    func test_init_shouldNotSendViewMessages() {
        let (_, viewSpy) = makeSUT()
                
        XCTAssertTrue(viewSpy.messages.isEmpty)
    }
    
    func test_didStartLoading_shouldReturnCorrectViewModelMessage() {
        let (sut, viewSpy) = makeSUT()
        let feedImage = anyUniqueFeedImage()
        
        sut.didStartLoading(model: anyUniqueFeedImage())
        
        XCTAssertEqual(viewSpy.messages, [toFeedCellViewModel(with: feedImage, isLoading: true, shouldRety: false)])
    }
    
    func test_didFinishLoadingWithError_shouldReturnCorrectViewModelMessage() {
        let (sut, viewSpy) = makeSUT()
        let feedImage = anyUniqueFeedImage()
        
        sut.didFinishLoadingWithError(model: feedImage)
        
        XCTAssertEqual(viewSpy.messages, [toFeedCellViewModel(with: feedImage, isLoading: false, shouldRety: true)])
    }
    
    func test_didFinishLoadingWithSuccess_shouldReturnCorrectViewModelMessage() {
        let (sut, viewSpy) = makeSUT()
        let data = anyData(value: UUID().description)
        let feedImage = anyUniqueFeedImage()
        let viewModel = toFeedCellViewModel(with: feedImage, isLoading: false, shouldRety: false, image: ImageStub(data: data))
        
        sut.didFinishLoadingWithSuccess(model: feedImage, imageData: data)
        
        XCTAssertEqual(viewSpy.messages, [viewModel])
    }
}

// MARK: - Helpers
private extension FeedImageCellPresenterTests {
    func makeSUT() -> (FeedImageCellPresenter<FeedImageViewSpy, ImageStub>, FeedImageViewSpy) {
        let viewSpy = FeedImageViewSpy()
        let sut = FeedImageCellPresenter(view: viewSpy, imageTransformer: ImageStub.init)
        
        return (sut, viewSpy)
    }
    
    func toFeedCellViewModel(with feedImage: FeedImage, isLoading: Bool, shouldRety: Bool, image: ImageStub? = nil) -> FeedCellViewModel<ImageStub> {
        return FeedCellViewModel<ImageStub>(location: feedImage.location,
                          description: feedImage.description,
                          isLoading: isLoading,
                          shouldRetry: shouldRety,
                          image: image)
    }
}

final class FeedImageViewSpy: FeedImageView {
    typealias Image = ImageStub
    var messages = [FeedCellViewModel<ImageStub>]()
    
    func display(model: FeedCellViewModel<ImageStub>) {
        messages.append(model)
    }
}

class ImageStub: Equatable {
    static func == (lhs: ImageStub, rhs: ImageStub) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String
    
    init(data: Data) {
        id = String(data: data, encoding: .utf8) ?? ""
    }
}
