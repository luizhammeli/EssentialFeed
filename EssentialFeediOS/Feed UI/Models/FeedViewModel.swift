////
////  FeedViewModel.swift
////  EssentialFeediOS
////
////  Created by Luiz Diniz Hammerli on 10/01/22.
////
//
//import Foundation
//import EssentialFeed
//
//public final class FeedViewModel {
//    typealias Observer<T> = (T) -> Void
//    private let feedLoader: FeedLoader
//
//    public init(feedLoader: FeedLoader) {
//        self.feedLoader = feedLoader
//    }
//    
//    var onFeedLoad: Observer<[FeedImage]>?
//    var onChange: Observer<Bool>?
//    
//    @objc func load() {
//        onChange?(true)
//        feedLoader.load(completion: { [weak self] result in
//            if let feedImage = try? result.get() {
//                self?.onFeedLoad?(feedImage)
//            }
//            self?.onChange?(false)
//        })
//    }
//}
