//
//  FeedImageHelpers.swift
//  EssentialAppTests
//
//  Created by Luiz Hammerli on 20/02/22.
//

import Foundation
import EssentialFeed

func anyFeedImage() -> FeedImage {
    let url = URL(string: "https://test.com")!
    return FeedImage(id: UUID(), url: url, description: nil, location: nil)
}
