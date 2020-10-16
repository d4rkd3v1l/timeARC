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

    func testByAdding() throws {
        let date = Date()
        let components = DateComponents(day: 1)
        let verification = try XCTUnwrap(Calendar.current.date(byAdding: DateComponents(day: 1), to: date))

        XCTAssertEqual(date.byAdding(components), verification)
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

    func testFirstOfYear() throws {
        let dateComponents = DateComponents(year: 2020, month: 1, day: 1)
        let firstOfYear = try XCTUnwrap(Calendar.current.date(from: dateComponents))
        XCTAssertEqual(self.date.firstOfYear, firstOfYear)
    }

    func testLastOfYear() throws {
        let dateComponents = DateComponents(year: 2020, month: 12, day: 31)
        let lastOfYear = try XCTUnwrap(Calendar.current.date(from: dateComponents))
        XCTAssertEqual(self.date.lastOfYear, lastOfYear)
    }

    func testFirstOfMonth() throws {
        let dateComponents = DateComponents(year: 2020, month: 7, day: 1)
        let firstOfMonth = try XCTUnwrap(Calendar.current.date(from: dateComponents))
        XCTAssertEqual(self.date.firstOfMonth, firstOfMonth)
    }

    func testLastOfMonth() throws {
        let dateComponents = DateComponents(year: 2020, month: 7, day: 31)
        let lastOfMonth = try XCTUnwrap(Calendar.current.date(from: dateComponents))
        XCTAssertEqual(self.date.lastOfMonth, lastOfMonth)
    }

    func testFirstOfWeek() throws {
        let dateComponents = DateComponents(year: 2020, month: 7, day: 19)
        let firstOfWeek = try XCTUnwrap(Calendar.current.date(from: dateComponents))
        XCTAssertEqual(self.date.firstOfWeek, firstOfWeek)
    }

    func testLastOfWeek() throws {
        let dateComponents = DateComponents(year: 2020, month: 7, day: 25)
        let lastOfWeek = try XCTUnwrap(Calendar.current.date(from: dateComponents))
        XCTAssertEqual(self.date.lastOfWeek, lastOfWeek)
    }

    func testFormatted() throws {
        XCTAssertEqual(self.date.formatted("HH:mm:ss"), "13:37:42")
        XCTAssertEqual(self.date.formatted("dd.MM.YYYY"), "20.07.2020")
    }

    func testHours() throws {
        XCTAssertEqual(self.date.hours, 13)
    }

    func testMinutes() throws {
        XCTAssertEqual(self.date.minutes, 37)
    }

    func testHoursAndMinutesInMinutes() throws {
        XCTAssertEqual(self.date.hoursAndMinutesInMinutes, 817)
    }

    func testWithTime() throws {
        let dateComponents = DateComponents(hour: 15, minute: 28, second: 31)
        let time = try XCTUnwrap(Calendar.current.date(from: dateComponents))

        let expectedDateComponents = DateComponents(year: 2020, month: 7, day: 20, hour: 15, minute: 28, second: 31)
        let expectedDate = try XCTUnwrap(Calendar.current.date(from: expectedDateComponents))
        XCTAssertEqual(self.date.withTime(from: time), expectedDate)
    }

    func testWithDate() throws {
        let dateComponents = DateComponents(year: 2021, month: 9, day: 14)
        let date = try XCTUnwrap(Calendar.current.date(from: dateComponents))

        let expectedDateComponents = DateComponents(year: 2021, month: 9, day: 14, hour: 13, minute: 37, second: 42)
        let expectedDate = try XCTUnwrap(Calendar.current.date(from: expectedDateComponents))
        XCTAssertEqual(self.date.withDate(from: date), expectedDate)
    }

    func testAverageTime() throws {
        let dateComponents = DateComponents(year: 2020, month: 8, day: 5, hour: 15, minute: 39, second: 44)
        let otherDate = try XCTUnwrap(Calendar.current.date(from: dateComponents))

        let dates: [Date] = [self.date, otherDate]

        let expectedDateComponents = DateComponents(hour: 14, minute: 38, second: 43)
        let expectedDate = try XCTUnwrap(Calendar.current.date(from: expectedDateComponents))
        let expectedAverageTime = try XCTUnwrap(Date().withTime(from: expectedDate))
        XCTAssertEqual(dates.averageTime, expectedAverageTime)
    }

    func testHoursAndMinutes() throws {
        let expectedDateComponents = DateComponents(hour: 2, minute: 3)
        let expectedDate = try XCTUnwrap(Calendar.current.date(from: expectedDateComponents))
        let expectedTime = try XCTUnwrap(Date().withTime(from: expectedDate))
        XCTAssertEqual(123.hoursAndMinutes, expectedTime)
    }

    func testDateFormat() throws {
        XCTAssertEqual(NSCalendar.Unit.hour.dateFormat, "HH")
        XCTAssertEqual(NSCalendar.Unit.minute.dateFormat, "mm")
        XCTAssertEqual(NSCalendar.Unit.second.dateFormat, "ss")
    }
}
