//
//  FeedCacheStore:.swift
//  EssentialFeedTests
//
//  Created by Luiz Diniz Hammerli on 29/11/21.
//

import Foundation
import EssentialFeed

func anyUniqueFeedImage() -> FeedImage {
    return .init(id: UUID(), url: makeURL(), description: nil, location: nil)
}

func anyUniqueFeedImages() -> (models: [FeedImage], localModels: [LocalFeedItem]) {
    let models = [anyUniqueFeedImage(), anyUniqueFeedImage()]
    let localModels = models.map { LocalFeedItem(id: $0.id, imageURL: $0.url, description: $0.description, location: $0.location) }
    return (models, localModels)
}

func testSpecificStoreURL(fileName: String) -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(fileName).store")
}

func deletesTestCache(fileName: String) {
    try? FileManager.default.removeItem(at: testSpecificStoreURL(fileName: fileName))
}

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        add(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays: Int {
        return 7
    }
    
    private func add(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func add(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
