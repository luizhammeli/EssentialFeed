//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Luiz Diniz Hammerli on 02/12/21.
//

import Foundation

final class FeedCachePolicy {
    static private var maxCacheAgeInDays: Int {
        return 7
    }
    
    static func isValid(_ timestamp: Date, against currentDate: Date) -> Bool {
        guard let limitDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        return currentDate < limitDate
    }
}
