//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Luiz Diniz Hammerli on 24/11/21.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedItems(completion: @escaping DeletionCompletion)
    func insert(items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
