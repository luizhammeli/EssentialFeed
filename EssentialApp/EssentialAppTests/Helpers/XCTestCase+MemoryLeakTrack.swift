//
//  XCTestCase+MemoryLeakTrack.swift
//  EssentialAppTests
//
//  Created by Luiz Hammerli on 20/02/22.
//

import XCTest

extension XCTestCase {
    func checkForMemoryLeaks(instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, file: file, line: line)
        }
    }
}
