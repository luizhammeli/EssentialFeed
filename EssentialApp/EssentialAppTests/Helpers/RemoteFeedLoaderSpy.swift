//
//  RemoteFeedLoaderSpy.swift
//  EssentialAppTests
//
//  Created by Luiz Hammerli on 20/02/22.
//

import EssentialFeed

final class RemoteFeedLoaderSpy: FeedLoader {
    var completions: [(FeedLoader.Result) -> Void] = []
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completions.append(completion)
    }
    
    func complete(with result: FeedLoader.Result, at index: Int = 0) {
        completions[index](result)
    }
}
