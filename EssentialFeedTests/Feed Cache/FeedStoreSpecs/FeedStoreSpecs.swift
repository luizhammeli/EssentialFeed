//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Luiz Diniz Hammerli on 24/12/21.
//

import Foundation

protocol FeedStoreSpecs {
    func test_retrive_deliversEmptyOnEmptyCache()

    func test_retrive_hasNoSideEffectsOnEmptyCache()

    func test_retrive_deliversFoundValueOnNonEmptyCache()

    func test_retrive_hasNoSideEffectsOnNonEmptyCache()

    func test_retrive_deliversErrorOnInvalidCache()

    func test_retrive_hasNoSideEffectsOnInvalidCache()

    func test_retrive_overridesPreviouslyInsertedCacheValue()

    func test_retrive_hasNoSideEffectsWhenOverridesPreviouslyInsertedCacheValue()

    func test_deleteCachedItems_deliversNoErrorWithEmptyCache()

    func test_deleteCachedItems_hasNoSideEffectOnEmptyCache()

    func test_deleteCachedItems_deliversNoErrorWithNonEmptyCache()

    func test_deleteCachedItems_deliversErrorOnDeletionError()

    func test_storeSideEffects_runSerially()
}
