//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Luiz Diniz Hammerli on 29/10/21.
//

import Foundation

public struct FeedItem: Codable {
    let id: UUID
    let imageURL: URL
    let description: String?
    let location: String?
}
