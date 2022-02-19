//
//  URLSessionHttpClient.swift
//  EssentialFeed
//
//  Created by Luiz Diniz Hammerli on 17/11/21.
//

import Foundation

public final class URLSessionHttpClient: HttpClient {
    private struct URLSessionHttpClientTask: HttpClientTask {
        let task: URLSessionDataTask
        
        init(task: URLSessionDataTask) {
            self.task = task
        }
        
        func cancel() {
            task.cancel()
        }
    }
    
    let urlSession: URLSession
    
    public init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    @discardableResult
    public func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) -> HttpClientTask {
       let task = urlSession.dataTask(with: url) { [weak self] data, response, error in
            guard self != nil else { return }
            if let error = error { return completion(.failure(error)) }
           
            guard let response = response as? HTTPURLResponse, let data = data else {
                completion(.failure(UnexpectedValuesRepresentation()))
                return
            }
            
            completion(.success((data, response)))
        }
        task.resume()
        return URLSessionHttpClientTask(task: task)
    }
}
