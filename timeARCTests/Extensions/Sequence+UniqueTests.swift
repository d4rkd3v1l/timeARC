//
//  Sequence+UniqueTests.swift
//  timeARCTests
//
//  Created by d4Rk on 15.11.20.
//

import XCTest
@testable import timeARC

class SequenceUniqueTests: XCTestCase {
    func testSequenceUnique() throws {
        XCTAssertEqual(["bli", "bla", "blub"].unique,  ["bli", "bla", "blub"])
    }

    func testSequenceUniqueWithDuplicates() throws {
        XCTAssertEqual(["bli", "bla", "blub", "bla"].unique,  ["bli", "bla", "blub"])
    }
}
