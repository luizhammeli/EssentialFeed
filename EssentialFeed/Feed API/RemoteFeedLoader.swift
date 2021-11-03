//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Luiz Diniz Hammerli on 03/11/21.
//

import Foundation

public protocol HttpClient {
    func get(from url: URL)
}

public final class RemoteFeedLoader: FeedLoader {
    private let client: HttpClient
    private let url: URL
    
    public init(url: URL, client: HttpClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (LoadFeedResult) -> Void) {
        client.get(from: url)
    }
}
