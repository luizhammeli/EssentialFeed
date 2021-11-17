//
//  HttpClient.swift
//  EssentialFeed
//
//  Created by Luiz Diniz Hammerli on 08/11/21.
//

import Foundation

public enum HttpClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
    
}

public protocol HttpClient {
    func get(from url: URL, completion: @escaping (HttpClientResult) -> Void)
}
