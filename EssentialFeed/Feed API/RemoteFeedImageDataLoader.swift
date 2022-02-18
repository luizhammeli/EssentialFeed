//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Luiz Hammerli on 17/02/22.
//

import Foundation

public final class DefaultFeedImageDataLoaderTask: FeedImageDataLoaderTask {
    let task: HttpClientTask
    
    init(task: HttpClientTask) {
        self.task = task
    }
    
    public func cancel() {
        task.cancel()
    }
}

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    let client: HttpClient
    
    public init(client: HttpClient) {
        self.client = client
    }
    
    @discardableResult
    public func loadFeedImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> FeedImageDataLoaderTask {
        let task = client.get(from: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success((let data, let response)):
                guard self.isValidResponseData(response: response, data: data) else {
                    return completion(.failure(NSError(domain: "", code: 1, userInfo: nil)))
                }
                completion(.success(data))
            }
        }
        return DefaultFeedImageDataLoaderTask(task: task)
    }
    
    private func isValidResponseData(response: HTTPURLResponse, data: Data) -> Bool {
        guard response.statusCode == 200, !data.isEmpty else { return false }
        return true
    }
}
