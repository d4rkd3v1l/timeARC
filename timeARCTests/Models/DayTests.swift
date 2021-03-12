//
//  WeekDayTests.swift
//  timeARCTests
//
//  Created by d4Rk on 12.10.20.
//

import XCTest
@testable import timeARC

class DayTests: XCTestCase {
    func testInit() throws {
        let day = Day()
        XCTAssertEqual(day.date, Date().startOfDay)
    }

    func testId() throws {
        let day = Day()
        XCTAssertEqual(day.id, day.date)
    }

    func testInitWithDate() throws {
        let date = Date()
        let day = Day(date)
        XCTAssertEqual(day.date, date.startOfDay)
    }

    func testAddingDays() throws {
        let date = Date()
        let dayAfterTomorrow = Day(date).addingDays(2)
        let dayAfterTomorrowVerification = try XCTUnwrap(Calendar.current.date(byAdding: DateComponents(day: 2), to: date)).startOfDay
        XCTAssertEqual(dayAfterTomorrow.date, dayAfterTomorrowVerification)

        let yesterday = Day(date).addingDays(-1)
        let yesterdayVerification = try XCTUnwrap(Calendar.current.date(byAdding: DateComponents(day: -1), to: date)).startOfDay
        XCTAssertEqual(yesterday.date, yesterdayVerification)
    }

    func testComparable() throws {
        let day1 = Day(Date()).addingDays(1)
        let day2 = Day(Date()).addingDays(2)
        XCTAssertLessThan(day1, day2)
    }

    func testDay() throws {
        let date = Date()
        XCTAssertEqual(date.day, Day(date))
    }
}
