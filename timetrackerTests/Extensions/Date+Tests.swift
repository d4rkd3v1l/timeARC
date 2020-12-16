//
//  DateTests.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import XCTest
@testable import timeARC

class DateTests: XCTestCase {
    var date: Date!

    override func setUpWithError() throws {
        self.date = try Date(year: 2020, month: 07, day: 20, hour: 13, minute: 37, second: 42)
    }

    func testDurationFormatted() throws {
        let dateOther = try Date(year: 2020, month: 07, day: 20, hour: 15, minute: 0, second: 0)

        XCTAssertEqual(self.date.durationFormatted(until: dateOther), "01:22")
        XCTAssertEqual(self.date.durationFormatted(until: dateOther, allowedUnits: [.hour, .minute]), "01:22")
        XCTAssertEqual(self.date.durationFormatted(until: dateOther, allowedUnits: [.hour, .minute, .second]), "01:22:18")
    }

    func testIsInSameDay() throws {
        let dateInSameDay = try Date(year: 2020, month: 07, day: 20, hour: 12, minute: 0, second: 0)
        XCTAssertTrue(self.date.isInSameDay(as: dateInSameDay))

        let dateNotInSameDay = try Date(year: 2020, month: 07, day: 21, hour: 12, minute: 0, second: 0)
        XCTAssertFalse(self.date.isInSameDay(as: dateNotInSameDay))
    }

    func testByAdding() throws {
        let date = Date()
        let components = DateComponents(day: 1)
        let verification = try XCTUnwrap(Calendar.current.date(byAdding: DateComponents(day: 1), to: date))

        XCTAssertEqual(date.byAdding(components), verification)
    }

    func testStartOfDay() throws {
        let dateStartOfDay = try Date(year: 2020, month: 07, day: 20, hour: 0, minute: 0, second: 0)

        XCTAssertEqual(self.date.startOfDay, dateStartOfDay)
    }

    func testEndOfDay() throws {
        let dateEndOfDay = try Date(year: 2020, month: 07, day: 20, hour: 23, minute: 59, second: 59)

        XCTAssertEqual(self.date.endOfDay, dateEndOfDay)
    }

    func testFirstOfYear() throws {
        let firstOfYear = try Date(year: 2020, month: 1, day: 1)
        XCTAssertEqual(self.date.firstOfYear, firstOfYear)
    }

    func testLastOfYear() throws {
        let lastOfYear = try Date(year: 2020, month: 12, day: 31)
        XCTAssertEqual(self.date.lastOfYear, lastOfYear)
    }

    func testFirstOfMonth() throws {
        let firstOfMonth = try Date(year: 2020, month: 7, day: 1)
        XCTAssertEqual(self.date.firstOfMonth, firstOfMonth)
    }

    func testLastOfMonth() throws {
        let lastOfMonth = try Date(year: 2020, month: 7, day: 31)
        XCTAssertEqual(self.date.lastOfMonth, lastOfMonth)
    }

    func testFirstOfWeek() throws {
        if Locale.current.identifier == "de_DE" {
            XCTAssertEqual(self.date.firstOfWeek, try Date(year: 2020, month: 7, day: 20))
        } else if Locale.current.identifier == "en_US" {
            XCTAssertEqual(self.date.firstOfWeek, try Date(year: 2020, month: 7, day: 19))
        } else {
            throw XCTSkip("Invalid locale for this test.")
        }
    }

    func testLastOfWeek() throws {
        if Locale.current.identifier == "de_DE" {
            XCTAssertEqual(self.date.lastOfWeek, try Date(year: 2020, month: 7, day: 26))
        } else if Locale.current.identifier == "en_US" {
            XCTAssertEqual(self.date.lastOfWeek, try Date(year: 2020, month: 7, day: 25))
        } else {
            throw XCTSkip("Invalid locale for this test.")
        }
    }

    func testFormatted() throws {
        XCTAssertEqual(self.date.formatted("HH:mm:ss"), "13:37:42")
        XCTAssertEqual(self.date.formatted("dd.MM.YYYY"), "20.07.2020")
    }

    func testFormattedTime() throws {
        if Locale.current.identifier == "de_DE" {
            XCTAssertEqual(self.date.formattedTime(), "13:37")
        } else if Locale.current.identifier == "en_US" {
            XCTAssertEqual(self.date.formattedTime(), "1:37 PM")
        } else {
            throw XCTSkip("Invalid locale for this test.")
        }
    }

    func testHours() throws {
        XCTAssertEqual(self.date.hours, 13)
    }

    func testMinutes() throws {
        XCTAssertEqual(self.date.minutes, 37)
    }

    func testHoursAndMinutesInSeconds() throws {
        XCTAssertEqual(self.date.hoursAndMinutesInSeconds, 49020)
    }

    func testWithTime() throws {
        let time = try Date(hour: 15, minute: 28, second: 31)

        let expectedDate = try Date(year: 2020, month: 7, day: 20, hour: 15, minute: 28, second: 31)
        XCTAssertEqual(self.date.withTime(from: time), expectedDate)
    }

    func testWithDate() throws {
        let date = try Date(year: 2021, month: 9, day: 14)

        let expectedDate = try Date(year: 2021, month: 9, day: 14, hour: 13, minute: 37, second: 42)
        XCTAssertEqual(self.date.withDate(from: date), expectedDate)
    }

    func testAverageTime() throws {
        let otherDate = try Date(year: 2020, month: 8, day: 5, hour: 15, minute: 39, second: 44)

        let dates: [Date] = [self.date, otherDate]

        let expectedDate = try Date(hour: 14, minute: 38, second: 43)
        let expectedAverageTime = try XCTUnwrap(Date().withTime(from: expectedDate))
        XCTAssertEqual(dates.averageTime, expectedAverageTime)
    }

    func testHoursAndMinutes() throws {
        let expectedDateComponents = DateComponents(hour: 2, minute: 3)
        let expectedDate = try XCTUnwrap(Calendar.current.date(from: expectedDateComponents))
        let expectedTime = try XCTUnwrap(Date().withTime(from: expectedDate))
        XCTAssertEqual(7380.hoursAndMinutes, expectedTime)
    }

    func testDateFormat() throws {
        XCTAssertEqual(NSCalendar.Unit.hour.dateFormat, "HH")
        XCTAssertEqual(NSCalendar.Unit.minute.dateFormat, "mm")
        XCTAssertEqual(NSCalendar.Unit.second.dateFormat, "ss")
    }
}
