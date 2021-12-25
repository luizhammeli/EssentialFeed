//
//  HttpClient.swift
//  EssentialFeed
//
//  Created by Luiz Diniz Hammerli on 08/11/21.
//

import Foundation

public protocol HttpClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
