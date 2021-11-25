//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Luiz Diniz Hammerli on 03/11/21.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let client: HttpClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalid
    }
    
    public init(url: URL, client: HttpClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (LoadFeedResult) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(let data, let response):
                do {
                    let items = try FeedItemMapper.map(data: data, statusCode: response.statusCode)
                    completion(.success(items.toModels()))
                } catch(let error) {
                    completion(.failure(error))
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static 
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedItem] {
        return map { FeedItem(id: $0.id, imageURL: $0.image, description: $0.description, location: $0.location) }
    }
}
