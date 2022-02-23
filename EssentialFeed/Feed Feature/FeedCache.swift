//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Luiz Hammerli on 22/02/22.
//

import Foundation

public protocol FeedCache {
    typealias SaveResult = Error?
    func save(images: [FeedImage], completion: @escaping (SaveResult) -> Void)
}
