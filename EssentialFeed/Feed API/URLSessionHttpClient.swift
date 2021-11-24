//
//  URLSessionHttpClient.swift
//  EssentialFeed
//
//  Created by Luiz Diniz Hammerli on 17/11/21.
//

import Foundation

public final class URLSessionHttpClient: HttpClient {
    let urlSession: URLSession
    
    public init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public func get(from url: URL, completion: @escaping (HttpClientResult) -> Void) {
        urlSession.dataTask(with: url) { [weak self] data, response, error in
            guard self != nil else { return }
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse, let data = data else {
                completion(.failure(UnexpectedValuesRepresentation()))
                return
            }
            
            completion(.success(data, response))
        }.resume()
    }
}
