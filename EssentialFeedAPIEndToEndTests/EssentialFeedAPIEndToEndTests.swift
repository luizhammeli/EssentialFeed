//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Luiz Diniz Hammerli on 20/11/21.
//

import XCTest
import EssentialFeed

final class EssentialFeedAPIEndToEndTests: XCTestCase {
    func test_endToEndTestServerGetFeedResult_matchesFixedTestAccountData() {
        let httpClient = URLSessionHttpClient(urlSession: URLSession(configuration: .ephemeral))
        let url = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: httpClient)

        let exp = expectation(description: "Waiting for request")
        remoteFeedLoader.load { [weak self] result in
            switch result {
            case .success(let feed):
                XCTAssertEqual(feed.count, 8, "Expected 8 itens in the test feed account")
                XCTAssertEqual(feed[0], self?.expectedItem(at: 0))
                XCTAssertEqual(feed[1], self?.expectedItem(at: 1))
                XCTAssertEqual(feed[2], self?.expectedItem(at: 2))
                XCTAssertEqual(feed[3], self?.expectedItem(at: 3))
                XCTAssertEqual(feed[4], self?.expectedItem(at: 4))
                XCTAssertEqual(feed[5], self?.expectedItem(at: 5))
                XCTAssertEqual(feed[6], self?.expectedItem(at: 6))
                XCTAssertEqual(feed[7], self?.expectedItem(at: 7))
            case .failure(let error):
                XCTFail("Expected success feed resul, got \(error) instead")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 10.0)
    }
}

extension EssentialFeedAPIEndToEndTests {
    private func getFeedResult() -> [FeedItem]{
        return [.init(id: UUID(uuidString: "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6")!,
                      imageURL: URL(string: "https://url-1.com")!,
                      description: "Description 1",
                      location: "Location 1"),
                .init(id: UUID(uuidString: "BA298A85-6275-48D3-8315-9C8F7C1CD109")!,
                              imageURL: URL(string: "https://url-2.com")!,
                              description: nil,
                              location: "Location 2"),
                .init(id: UUID(uuidString: "5A0D45B3-8E26-4385-8C5D-213E160A5E3C")!,
                              imageURL: URL(string: "https://url-3.com")!,
                              description: "Description 3",
                              location: nil),
                .init(id: UUID(uuidString: "FF0ECFE2-2879-403F-8DBE-A83B4010B340")!,
                              imageURL: URL(string: "https://url-4.com")!,
                              description: nil,
                              location: nil),
                .init(id: UUID(uuidString: "DC97EF5E-2CC9-4905-A8AD-3C351C311001")!,
                              imageURL: URL(string: "https://url-5.com")!,
                              description: "Description 5",
                              location: "Location 5"),
                .init(id: UUID(uuidString: "557D87F1-25D3-4D77-82E9-364B2ED9CB30")!,
                              imageURL: URL(string: "https://url-6.com")!,
                              description: "Description 6",
                              location: "Location 6"),
                .init(id: UUID(uuidString: "A83284EF-C2DF-415D-AB73-2A9B8B04950B")!,
                              imageURL: URL(string: "https://url-7.com")!,
                              description: "Description 7",
                              location: "Location 7"),
                .init(id: UUID(uuidString: "F79BD7F8-063F-46E2-8147-A67635C3BB01")!,
                              imageURL: URL(string: "https://url-8.com")!,
                              description: "Description 8",
                              location: "Location 8")]
    }
    private func expectedItem(at index: Int) -> FeedItem {
        return getFeedResult()[index]
    }
}
