//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Luiz Diniz Hammerli on 08/11/21.
//

import Foundation

internal struct RemoteFeedItem: Equatable, Codable {
    let id: UUID
    let image: URL
    let description: String?
    let location: String?
}

internal final class FeedItemMapper {
    private struct RootFeed: Equatable, Codable {
        let items: [RemoteFeedItem]
    }
    
    private static let OK_200: Int = 200
    
   internal static func map(data: Data, statusCode: Int) throws -> [RemoteFeedItem] {
        guard statusCode == OK_200, let rootFeed = try? JSONDecoder().decode(RootFeed.self, from: data) else { throw RemoteFeedLoader.Error.invalid }        
        return rootFeed.items
    }
}
