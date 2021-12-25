//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Luiz Diniz Hammerli on 24/11/21.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedItem], timestamp: Date)

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievedResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievedResult) -> Void
    
    func deleteCachedItems(completion: @escaping DeletionCompletion)
    func insert(items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrive(completion: @escaping RetrievalCompletion)
}

public struct LocalFeedItem: Equatable {
    public let id: UUID
    public let imageURL: URL
    public let description: String?
    public let location: String?
    
    public init(id: UUID, imageURL: URL, description: String?, location: String?) {
        self.id = id
        self.imageURL = imageURL
        self.description = description
        self.location = location
    }
}
