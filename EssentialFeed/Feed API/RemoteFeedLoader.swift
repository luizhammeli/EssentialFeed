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
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success((let data, let response)):
                completion(self.map(data: data, statusCode: response.statusCode))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private func map(data: Data, statusCode: Int) -> FeedLoader.Result {
        do {
            let items = try FeedItemMapper.map(data: data, statusCode: statusCode)
            return .success(items.toModels())
        } catch(let error) {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, url: $0.image, description: $0.description, location: $0.location) }
    }
}
