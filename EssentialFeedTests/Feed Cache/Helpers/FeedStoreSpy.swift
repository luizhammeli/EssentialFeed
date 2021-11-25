//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Luiz Diniz Hammerli on 25/11/21.
//

import Foundation
import EssentialFeed

final class FeedStoreSpy: FeedStore {
    enum ReceivedMessages: Equatable {
        case deleteCachedFeeds
        case insertFeeds([LocalFeedItem], Date)
        case retreive
    }
    
    private(set) var deletionCompletions: [FeedStore.DeletionCompletion] = []
    private(set) var insertCompletions: [FeedStore.InsertionCompletion] = []
    private(set) var retreiveCompletions: [FeedStore.RetreiveCompletion] = []
    private(set) var messages: [ReceivedMessages] = []
    
    func deleteCachedItems(completion: @escaping FeedStore.DeletionCompletion) {
        deletionCompletions.append(completion)
        messages.append(.deleteCachedFeeds)
    }
    
    func insert(items: [LocalFeedItem], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        messages.append(.insertFeeds(items, timestamp))
        insertCompletions.append(completion)
    }
    
    func retreive(completion: @escaping (Error?) -> Void) {
        messages.append(.retreive)
        retreiveCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletion(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertCompletions[index](nil)
    }
    
    func completreRetreive(with error: Error, at index: Int = 0) {
        retreiveCompletions[index](error)
    }
}
