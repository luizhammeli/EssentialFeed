//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Luiz Diniz Hammerli on 02/11/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (Swift.Error) -> Void)
}
