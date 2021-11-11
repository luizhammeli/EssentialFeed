//
//  XCTestCase+MemoryLeakTrack.swift
//  EssentialFeedTests
//
//  Created by Luiz Diniz Hammerli on 10/11/21.
//

import Foundation
import XCTest

extension XCTestCase {
    func checkForMemoryLeaks(instance: AnyObject) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance)
        }
    }
}
