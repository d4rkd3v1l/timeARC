//
//  WeekDayTests.swift
//  timeARCTests
//
//  Created by d4Rk on 12.10.20.
//

import XCTest
@testable import timeARC

extension WeekDay: Localized {}

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
        XCTAssertEqual(WeekDay.sunday.sortIndex, try .localized(en: 0, de: 6))
        XCTAssertEqual(WeekDay.monday.sortIndex, try .localized(en: 1, de: 0))
        XCTAssertEqual(WeekDay.tuesday.sortIndex, try .localized(en: 2, de: 1))
        XCTAssertEqual(WeekDay.wednesday.sortIndex, try .localized(en: 3, de: 2))
        XCTAssertEqual(WeekDay.thursday.sortIndex, try .localized(en: 4, de: 3))
        XCTAssertEqual(WeekDay.friday.sortIndex, try .localized(en: 5, de: 4))
        XCTAssertEqual(WeekDay.saturday.sortIndex, try .localized(en: 6, de: 5))
    }

    func testComparable() throws {
        XCTAssertGreaterThan(WeekDay.thursday, WeekDay.wednesday)
    }

    func testSymbol() throws {
        XCTAssertEqual(WeekDay.monday.symbol, try .localized(en: "Monday",
                                                             de: "Montag"))
    }

    func testShortSymbol() throws {
        XCTAssertEqual(WeekDay.monday.shortSymbol, try .localized(en: "Mon",
                                                                  de: "Mo."))
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
