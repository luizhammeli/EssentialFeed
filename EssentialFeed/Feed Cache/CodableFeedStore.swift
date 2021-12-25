//
//  File.swift
//  EssentialFeed
//
//  Created by Luiz Diniz Hammerli on 14/12/21.
//

import Foundation

public final class CodableFeedStore: FeedStore {
    private struct Cache: Codable {
        let items: [CodableFeedItem]
        let timestamp: Date
        
        func localItems() -> [LocalFeedItem] {
            return items.map { $0.toLocal() }
        }
    }
    
    private struct CodableFeedItem: Codable {
        public let id: UUID
        public let imageURL: URL
        public let description: String?
        public let location: String?
        
        init(_ localFeedImage: LocalFeedItem) {
            self.id = localFeedImage.id
            self.imageURL = localFeedImage.imageURL
            self.description = localFeedImage.description
            self.location = localFeedImage.location
        }
        
        func toLocal() -> LocalFeedItem {
            return LocalFeedItem(id: id, imageURL: imageURL, description: description, location: location)
        }
    }
    
    private let storeURL: URL
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func deleteCachedItems(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else { return completion(nil) }
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch(let error) {
                completion(error)
            }
        }
    }
    
    public func insert(items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let cache = Cache(items: items.map { CodableFeedItem.init($0) }, timestamp: timestamp)
                let data = try JSONEncoder().encode(cache)
                try data.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrive(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else { return completion(.success(nil)) }
            
            do {
                let cache = try JSONDecoder().decode(Cache.self, from: data)
                completion(.success((cache.localItems(), timestamp: cache.timestamp)))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
