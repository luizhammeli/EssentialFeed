//
//  FeedImageStore.swift
//  EssentialFeed
//
//  Created by Luiz Hammerli on 27/03/22.
//

import Foundation

public protocol FeedImageStore {
    typealias Result = Swift.Result<Data, Error>
    func insert(url: URL, data: Data)
    func retrive(url: URL, completion: @escaping (Result) -> Void)
}
