//
//  WeekDayTests.swift
//  timetrackerTests
//
//  Created by d4Rk on 12.10.20.
//

import XCTest
@testable import timeARC

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

    func testWorkingDays() throws {
        let startDate = try Date(year: 2020, month: 11, day: 1)
        let endDate = try Date(year: 2020, month: 11, day: 11)
        let workingWeekDays: [WeekDay] = [.monday,
                                          .tuesday,
                                          .wednesday,
                                          .thursday,
                                          .friday]

        let workingDays = workingWeekDays.workingDays(startDate: startDate, endDate: endDate)

        XCTAssertEqual(workingDays, [try Date(year: 2020, month: 11, day: 2).day,
                                     try Date(year: 2020, month: 11, day: 3).day,
                                     try Date(year: 2020, month: 11, day: 4).day,
                                     try Date(year: 2020, month: 11, day: 5).day,
                                     try Date(year: 2020, month: 11, day: 6).day,
                                     try Date(year: 2020, month: 11, day: 9).day,
                                     try Date(year: 2020, month: 11, day: 10).day,
                                     try Date(year: 2020, month: 11, day: 11).day])
    }

    func testRelevantDaysForTimeEntriesAndAbsenceEntries() throws {
        let timeEntryStartDate = try Date(year: 2020, month: 11, day: 1, hour: 8, minute: 12, second: 42)
        let timeEntryEndDate = try Date(year: 2020, month: 11, day: 1, hour: 15, minute: 34, second: 2)
        let timeEntry = TimeEntry(start: timeEntryStartDate, end: timeEntryEndDate)

        let absenceEntryStartDate = try Date(year: 2020, month: 11, day: 2)
        let absenceEntryEndDate = try Date(year: 2020, month: 11, day: 3)
        let absenceEntry = AbsenceEntry(type: .dummy, start: absenceEntryStartDate.day, end: absenceEntryEndDate.day)

        let workingWeekDays: [WeekDay] = [.monday,
                                          .tuesday,
                                          .wednesday,
                                          .thursday,
                                          .friday]

        let workingDays = workingWeekDays.relevantDays(for: [timeEntryStartDate.day: [timeEntry]],
                                                       absenceEntries: [absenceEntry])

        XCTAssertEqual(workingDays, [try Date(year: 2020, month: 11, day: 1).day, // Note: sunday
                                     try Date(year: 2020, month: 11, day: 2).day,
                                     try Date(year: 2020, month: 11, day: 3).day])
    }
}
