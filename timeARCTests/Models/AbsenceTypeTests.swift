//
//  AbsenceTypeTests.swift
//  timeARCTests
//
//  Created by d4Rk on 12.03.21.
//

import XCTest
@testable import timeARC

class AbsenceTypeTests: XCTestCase {
    func testLocalizedtitle() throws {
        let absenceType = AbsenceType(id: UUID(), title: "Test", icon: "😈", offPercentage: 13.37)
        XCTAssertEqual(absenceType.localizedTitle, "😈 Test")
    }
}
