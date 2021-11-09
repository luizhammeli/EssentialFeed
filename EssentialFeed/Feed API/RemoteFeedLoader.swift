//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Luiz Diniz Hammerli on 03/11/21.
//

import Foundation

public enum HttpClientResult {
    case success(Data, HTTPURLResponse)
    case error(Error)
}

public protocol HttpClient {
    func get(from url: URL, completion: @escaping (HttpClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let client: HttpClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalid
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HttpClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (RemoteFeedLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success(let data, let response):
                do {
                    let feedItems = try FeedItemMapper.mapToFeedItems(data: data, statusCode: response.statusCode)
                    completion(.success(feedItems))
                } catch {
                    completion(.failure(Error.invalid))
                }
            case .error:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

final class FeedItemMapper {
    private struct RootFeed: Equatable, Codable {
        let items: [RemoteFeed]
        
        public init(items: [RemoteFeed]) {
            self.items = items
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
    
    static func mapToFeedItems(data: Data, statusCode: Int) throws -> [FeedItem] {
        guard statusCode == 200 else { throw RemoteFeedLoader.Error.invalid }
        
        let feed = try JSONDecoder().decode(RootFeed.self, from: data)
        return feed.items.map { $0.item }
    }
}
