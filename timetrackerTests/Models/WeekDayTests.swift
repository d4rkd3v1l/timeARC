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

    func testSortIndex() throws {
        if Locale.current.identifier == "de_DE" {
            XCTAssertEqual(WeekDay.sunday.sortIndex, 6)
            XCTAssertEqual(WeekDay.monday.sortIndex, 0)
            XCTAssertEqual(WeekDay.tuesday.sortIndex, 1)
            XCTAssertEqual(WeekDay.wednesday.sortIndex, 2)
            XCTAssertEqual(WeekDay.thursday.sortIndex, 3)
            XCTAssertEqual(WeekDay.friday.sortIndex, 4)
            XCTAssertEqual(WeekDay.saturday.sortIndex, 5)
        } else if Locale.current.identifier == "en_US" {
            XCTAssertEqual(WeekDay.sunday.sortIndex, 0)
            XCTAssertEqual(WeekDay.monday.sortIndex, 1)
            XCTAssertEqual(WeekDay.tuesday.sortIndex, 2)
            XCTAssertEqual(WeekDay.wednesday.sortIndex, 3)
            XCTAssertEqual(WeekDay.thursday.sortIndex, 4)
            XCTAssertEqual(WeekDay.friday.sortIndex, 5)
            XCTAssertEqual(WeekDay.saturday.sortIndex, 6)
        } else {
            throw XCTSkip("Invalid locale for this test.")
        }
    }

    func testComparable() throws {
        XCTAssertGreaterThan(WeekDay.thursday, WeekDay.wednesday)
    }

    func testSymbol() throws {
        if Locale.current.identifier == "de_DE" {
            XCTAssertEqual(WeekDay.monday.symbol, "Montag")
        } else if Locale.current.identifier == "en_US" {
            XCTAssertEqual(WeekDay.monday.symbol, "Monday")
        } else {
            throw XCTSkip("Invalid locale for this test.")
        }
    }

    func testShortSymbol() throws {
        if Locale.current.identifier == "de_DE" {
            XCTAssertEqual(WeekDay.monday.shortSymbol, "Mo.")
        } else if Locale.current.identifier == "en_US" {
            XCTAssertEqual(WeekDay.monday.shortSymbol, "Mon")
        } else {
            throw XCTSkip("Invalid locale for this test.")
        }
    }

    func testAvailableItems() throws {

        if Locale.current.identifier == "de_DE" {
            XCTAssertEqual(WeekDay.availableItems, [.monday,
                                                    .tuesday,
                                                    .wednesday,
                                                    .thursday,
                                                    .friday,
                                                    .saturday,
                                                    .sunday])
        } else if Locale.current.identifier == "en_US" {
            XCTAssertEqual(WeekDay.availableItems, [.sunday,
                                                    .monday,
                                                    .tuesday,
                                                    .wednesday,
                                                    .thursday,
                                                    .friday,
                                                    .saturday])
        } else {
            throw XCTSkip("Invalid locale for this test.")
        }
    }

    func testTitle() throws {
        if Locale.current.identifier == "de_DE" {
            XCTAssertEqual(WeekDay.monday.title, "Montag")
        } else if Locale.current.identifier == "en_US" {
            XCTAssertEqual(WeekDay.monday.title, "Monday")
        } else {
            throw XCTSkip("Invalid locale for this test.")
        }
    }
}
