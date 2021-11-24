//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Luiz Diniz Hammerli on 29/10/21.
//

import Foundation

public struct FeedItem: Equatable, Decodable {
    let id: UUID
    let imageURL: URL
    let description: String?
    let location: String?
    
    public init(id: UUID, imageURL: URL, description: String?, location: String?) {
        self.id = id
        self.imageURL = imageURL
        self.description = description
        self.location = location
    }
}
