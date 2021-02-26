//
//  ExpansionHandlerTests.swift
//  timeARCTests
//
//  Created by d4Rk on 04.10.20.
//

import XCTest
@testable import timeARC

class ExpansionHandlerTests: XCTestCase {
    func testIsExpaneded() throws {
        let item = "SomeItem"
        let expansionHandler = ExpansionHandler<String>()
        let isExpandedBinding = expansionHandler.isExpanded(item)
        XCTAssertFalse(isExpandedBinding.wrappedValue)

        isExpandedBinding.wrappedValue = true
        XCTAssertTrue(isExpandedBinding.wrappedValue)

        isExpandedBinding.wrappedValue = false
        XCTAssertFalse(isExpandedBinding.wrappedValue)
    }

    func testToggleExpanded() throws {
        let item = "SomeItem"
        let expansionHandler = ExpansionHandler<String>()

        expansionHandler.toggleExpanded(for: item)
        XCTAssertTrue(expansionHandler.isExpanded(item).wrappedValue)

        expansionHandler.toggleExpanded(for: item)
        XCTAssertFalse(expansionHandler.isExpanded(item).wrappedValue)
    }
}
