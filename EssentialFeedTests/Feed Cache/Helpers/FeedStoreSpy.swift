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
        case retrive
    }
    
    private(set) var deletionCompletions: [FeedStore.DeletionCompletion] = []
    private(set) var insertCompletions: [FeedStore.InsertionCompletion] = []
    private(set) var retreiveCompletions: [FeedStore.RetrievalCompletion] = []
    private(set) var messages: [ReceivedMessages] = []
    
    func deleteCachedItems(completion: @escaping FeedStore.DeletionCompletion) {
        deletionCompletions.append(completion)
        messages.append(.deleteCachedFeeds)
    }
    
    func insert(items: [LocalFeedItem], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        messages.append(.insertFeeds(items, timestamp))
        insertCompletions.append(completion)
    }
    
    func retrive(completion: @escaping FeedStore.RetrievalCompletion) {
        messages.append(.retrive)
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
        retreiveCompletions[index](.failure(error))
    }
    
    func completeRetriveWithEmptyData(at index: Int = 0) {
        retreiveCompletions[index](.success(nil))
    }
    
    func completeRetrive(with data: [LocalFeedItem], timestamp: Date = Date(), at index: Int = 0) {
        retreiveCompletions[index](.success((data, timestamp: timestamp)))
    }
}
