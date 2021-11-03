//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Luiz Diniz Hammerli on 02/11/21.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
