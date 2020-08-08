//
//  DateTests.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import XCTest
@testable import timetracker

class DateTests: XCTestCase {
    var date: Date!

    override func setUpWithError() throws {
        let dateComponents = DateComponents(year: 2020, month: 07, day: 20, hour: 13, minute: 37, second: 42)
        self.date = try XCTUnwrap(Calendar.current.date(from: dateComponents))
    }

    func testDurationFormatted() throws {
        let dateComponentsOther = DateComponents(year: 2020, month: 07, day: 20, hour: 15, minute: 0, second: 0)
        let dateOther = try XCTUnwrap(Calendar.current.date(from: dateComponentsOther))

        XCTAssertEqual(self.date.durationFormatted(until: dateOther), "01:22")
        XCTAssertEqual(self.date.durationFormatted(until: dateOther, allowedUnits: [.hour, .minute]), "01:22")
        XCTAssertEqual(self.date.durationFormatted(until: dateOther, allowedUnits: [.hour, .minute, .second]), "01:22:18")
    }

    func testIsInSameDay() throws {
        let dateComponentsInSameDay = DateComponents(year: 2020, month: 07, day: 20, hour: 12, minute: 0, second: 0)
        let dateInSameDay = try XCTUnwrap(Calendar.current.date(from: dateComponentsInSameDay))
        XCTAssertTrue(self.date.isInSameDay(as: dateInSameDay))

        let dateComponentsNotInSameDay = DateComponents(year: 2020, month: 07, day: 21, hour: 12, minute: 0, second: 0)
        let dateNotInSameDay = try XCTUnwrap(Calendar.current.date(from: dateComponentsNotInSameDay))
        XCTAssertFalse(self.date.isInSameDay(as: dateNotInSameDay))
    }

    func testStartOfDay() throws {
        let dateComponentsStartOfDay = DateComponents(year: 2020, month: 07, day: 20, hour: 0, minute: 0, second: 0)
        let dateStartOfDay = try XCTUnwrap(Calendar.current.date(from: dateComponentsStartOfDay))

        XCTAssertEqual(self.date.startOfDay, dateStartOfDay)
    }

    func testEndOfDay() throws {
        let dateComponentsEndOfDay = DateComponents(year: 2020, month: 07, day: 20, hour: 23, minute: 59, second: 59)
        let dateEndOfDay = try XCTUnwrap(Calendar.current.date(from: dateComponentsEndOfDay))

        XCTAssertEqual(self.date.endOfDay, dateEndOfDay)
    }
}
