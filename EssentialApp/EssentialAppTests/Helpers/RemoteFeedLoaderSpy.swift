//
//  RemoteFeedLoaderSpy.swift
//  EssentialAppTests
//
//  Created by Luiz Hammerli on 20/02/22.
//

import EssentialFeed

final class RemoteFeedLoaderSpy: FeedLoader, FeedCache {
    enum Messages: Equatable {
        case save
        case load
    }
    
    var completions: [(FeedLoader.Result) -> Void] = []
    var messages: [Messages] = []
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completions.append(completion)
        messages.append(.load)
    }
    
    func save(images: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        messages.append(.save)
    }
    
    func complete(with result: FeedLoader.Result, at index: Int = 0) {
        completions[index](result)
    }
}
