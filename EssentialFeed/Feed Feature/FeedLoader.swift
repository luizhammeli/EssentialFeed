//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Luiz Diniz Hammerli on 02/11/21.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping (Result) -> Void)
}
