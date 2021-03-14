//
//  Sequence+UniqueTests.swift
//  timeARCTests
//
//  Created by d4Rk on 15.11.20.
//

import XCTest
@testable import timeARC

class SequenceDuplicatesTests: XCTestCase {
    func testSequenceDuplicates() throws {
        XCTAssertEqual(["bli", "bla", "blub", "bla", "bla"].duplicates(by: { $0 }), ["bla", "bla"])
    }

    func testSequenceDuplicatesWithoutDuplicates() throws {
        XCTAssertEqual(["bli", "bla", "blub"].duplicates(by: { $0 }), [])
    }
}
