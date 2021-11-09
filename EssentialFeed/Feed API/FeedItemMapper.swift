//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Luiz Diniz Hammerli on 08/11/21.
//

import Foundation

final class FeedItemMapper {
    private struct RootFeed: Equatable, Codable {
        let items: [RemoteFeed]
        var feed: [FeedItem] {
            items.map { $0.item }
        }
    }
    
    private struct RemoteFeed: Equatable, Codable {
        let id: UUID
        let image: URL
        let description: String?
        let location: String?
        
        var item: FeedItem {
            FeedItem(id: id, imageURL: image, description: description, location: location)
        }
    }
    
    private static let OK_200: Int = 200
    
    static func mapToFeedItems(data: Data, statusCode: Int) -> RemoteFeedLoader.Result {
        guard statusCode == OK_200, let rootFeed = try? JSONDecoder().decode(RootFeed.self, from: data) else { return .failure(RemoteFeedLoader.Error.invalid) }
        
        return .success(rootFeed.feed)
    }
}
