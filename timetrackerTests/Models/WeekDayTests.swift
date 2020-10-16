//
//  WeekDayTests.swift
//  timetrackerTests
//
//  Created by d4Rk on 12.10.20.
//

import XCTest
@testable import timetracker

class WeekDayTests: XCTestCase {
    func testId() throws {
        let weekDay: WeekDay = .friday
        XCTAssertEqual(weekDay.id, weekDay)
    }

    func testInit() throws {
        let weekDay = WeekDay(4)
        XCTAssertEqual(weekDay, .wednesday)

        let invalidWeekDay = WeekDay(1337)
        XCTAssertEqual(invalidWeekDay, .monday)
    }

    func testSortIndex_de() throws {
        guard Locale.current.identifier == "de" else { throw XCTSkip("Invalid locale for this test.") }
        XCTAssertEqual(WeekDay.sunday.sortIndex, 6)
        XCTAssertEqual(WeekDay.monday.sortIndex, 0)
        XCTAssertEqual(WeekDay.tuesday.sortIndex, 1)
        XCTAssertEqual(WeekDay.wednesday.sortIndex, 2)
        XCTAssertEqual(WeekDay.thursday.sortIndex, 3)
        XCTAssertEqual(WeekDay.friday.sortIndex, 4)
        XCTAssertEqual(WeekDay.saturday.sortIndex, 5)
    }

    func testSortIndex_en() throws {
        guard Locale.current.identifier == "en" else { throw XCTSkip("Invalid locale for this test.") }
        XCTAssertEqual(WeekDay.sunday.sortIndex, 0)
        XCTAssertEqual(WeekDay.monday.sortIndex, 1)
        XCTAssertEqual(WeekDay.tuesday.sortIndex, 2)
        XCTAssertEqual(WeekDay.wednesday.sortIndex, 3)
        XCTAssertEqual(WeekDay.thursday.sortIndex, 4)
        XCTAssertEqual(WeekDay.friday.sortIndex, 5)
        XCTAssertEqual(WeekDay.saturday.sortIndex, 6)
    }

    func testComparable() throws {
        XCTAssertGreaterThan(WeekDay.thursday, WeekDay.wednesday)
    }

    func testSymbol() throws {
        XCTAssertEqual(WeekDay.monday.symbol, "Monday")
    }

    func testShortSymbol() throws {
        XCTAssertEqual(WeekDay.monday.shortSymbol, "Mon")
    }

    func testAvailableItems() throws {
        XCTAssertEqual(WeekDay.availableItems, [.sunday,
                                                .monday,
                                                .tuesday,
                                                .wednesday,
                                                .thursday,
                                                .friday,
                                                .saturday])
    }

    func testTitle() throws {
        XCTAssertEqual(WeekDay.monday.title, "Monday")
    }
}
