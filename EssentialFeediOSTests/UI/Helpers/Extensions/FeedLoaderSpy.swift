//
//  FeedLoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Luiz Hammerli on 06/02/22.
//

import Foundation
import EssentialFeediOS
import EssentialFeed

class FeedLoaderSpy: FeedLoader, FeedImageDataLoader {
    // MARK: - FeedLoader
    private var loadCompletionMessages = [(FeedLoader.Result) -> Void]()
    
    var loadCompletionMessagesCount: Int {
        loadCompletionMessages.count
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        loadCompletionMessages.append(completion)
    }
    
    func completeFeedLoader(with result: FeedLoader.Result = .success([]), at index: Int = 0) {
        loadCompletionMessages[index](result)
    }
    
    // MARK: - FeedImageDataLoaderTask
    private(set) var canceledTasks = [URL]()
    private struct LoadImageTaskSpy: FeedImageDataLoaderTask {
        let completion: (() -> Void)
        
        func cancel() {
            completion()
        }
    }
    
    // MARK: - FeedImageDataLoader
    var loadImagesURLs: [URL] {
        return feedImageDataCompletions.map { $0.url }
    }
    private(set) var feedImageDataCompletions = [(url: URL, completion: ((Swift.Result<Data, Error>) -> Void))]()

    func loadFeedImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> FeedImageDataLoaderTask {
        feedImageDataCompletions.append((url, completion))
        return LoadImageTaskSpy { [weak self] in self?.canceledTasks.append(url) }
    }
    
    func completeImageLoading(with result: Swift.Result<Data, Error>, at index: Int = 0) {
        feedImageDataCompletions[index].completion(result)
    }
}
