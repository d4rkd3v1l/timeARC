//
//  CodableColorTests.swift
//  timetrackerTests
//
//  Created by d4Rk on 04.10.20.
//

import XCTest
@testable import timetracker

class CodableColorTests: XCTestCase {
    func testContrastColor() throws {
        let pink = CodableColor.pink
        XCTAssertEqual(pink.contrastColor(for: .light), .primary)
        XCTAssertEqual(pink.contrastColor(for: .dark), .primary)

        let primary = CodableColor.primary
        XCTAssertEqual(primary.contrastColor(for: .light), .white)
        XCTAssertEqual(primary.contrastColor(for: .dark), .black)
    }
}
