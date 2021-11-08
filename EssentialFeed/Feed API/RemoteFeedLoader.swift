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
    y
    public func load(completion: @escaping (RemoteFeedLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success(let data, _):
                if let feed = try? JSONDecoder().decode(RootFeed.self, from: data) {
                    completion(.success(feed.items))
                } else {
                    completion(.failure(Error.invalid))
                }
            case .error:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
