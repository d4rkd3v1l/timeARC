//
//  TimeEntryTests.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import XCTest
@testable import timetracker

class TimeEntryTests: XCTestCase {
    var dateStart: Date!
    var dateEnd: Date!
    var dateReference: Date!

    override func setUpWithError() throws {
        let dateComponentsStart = DateComponents(year: 2020, month: 07, day: 20, hour: 13, minute: 37, second: 42)
        self.dateStart = try XCTUnwrap(Calendar.current.date(from: dateComponentsStart))

        let dateComponentsEnd = DateComponents(year: 2020, month: 07, day: 20, hour: 15, minute: 00, second: 00)
        self.dateEnd = try XCTUnwrap(Calendar.current.date(from: dateComponentsEnd))

        let dateComponentsReference = DateComponents(year: 2020, month: 07, day: 20)
        self.dateReference = try XCTUnwrap(Calendar.current.date(from: dateComponentsReference))
    }

    func testActualEnd() throws {
        let timeEntry = TimeEntry(start: self.dateStart)
        XCTAssertEqual(timeEntry.actualEnd.timeIntervalSinceReferenceDate,
                       Date(timeIntervalSinceNow: 0).timeIntervalSinceReferenceDate,
                       accuracy: 0.001)

        let timeEntryWithExplicitEnd = TimeEntry(start: self.dateStart, end: self.dateEnd)
        XCTAssertEqual(timeEntryWithExplicitEnd.actualEnd, self.dateEnd)
    }

    func testDurationFormatted() throws {
        let timeEntry = TimeEntry(start: self.dateStart, end: self.dateEnd)
        XCTAssertEqual(timeEntry.durationFormatted(), "01:22")
        XCTAssertEqual(timeEntry.durationFormatted(allowedUnits: [.hour, .minute]), "01:22")
        XCTAssertEqual(timeEntry.durationFormatted(allowedUnits: [.hour, .minute, .second]), "01:22:18")
    }

    func testIsRelevant() throws {
        let dateComponentsDay1 = DateComponents(year: 2020, month: 07, day: 19, hour: 13, minute: 37, second: 42)
        let dateDay1 = try XCTUnwrap(Calendar.current.date(from: dateComponentsDay1))

        let dateComponentsDay2 = DateComponents(year: 2020, month: 07, day: 20, hour: 6, minute: 6, second: 6)
        let dateDay2 = try XCTUnwrap(Calendar.current.date(from: dateComponentsDay2))

        let dateComponentsDay3 = DateComponents(year: 2020, month: 07, day: 21, hour: 13, minute: 37, second: 42)
        let dateDay3 = try XCTUnwrap(Calendar.current.date(from: dateComponentsDay3))

        let timeEntryWithRelevantStart = TimeEntry(start: dateDay2)
        XCTAssertTrue(timeEntryWithRelevantStart.isRelevant(for: self.dateReference))

        let timeEntryWithRelevantEnd = TimeEntry(start: dateDay1, end: dateDay2)
        XCTAssertTrue(timeEntryWithRelevantEnd.isRelevant(for: self.dateReference))

        let timeEntryWithRelevantBetween = TimeEntry(start: dateDay1, end: dateDay3)
        XCTAssertTrue(timeEntryWithRelevantBetween.isRelevant(for: self.dateReference))

        let timeEntryWithNoRelevance = TimeEntry(start: dateDay1, end: dateDay1)
        XCTAssertFalse(timeEntryWithNoRelevance.isRelevant(for: self.dateReference))
    }

    func testDurationInSeconds() throws {
        let timeEntry = TimeEntry(start: self.dateStart, end: self.dateEnd)
        XCTAssertEqual(timeEntry.durationInSeconds(on: self.dateReference), 4938)

        let dateComponentsOtherDay = DateComponents(year: 2020, month: 07, day: 21)
        let dateOtherDay = try XCTUnwrap(Calendar.current.date(from: dateComponentsOtherDay))
        XCTAssertEqual(timeEntry.durationInSeconds(on: dateOtherDay), nil)

        let dateComponentsStartOtherDay = DateComponents(year: 2020, month: 07, day: 19, hour: 23)
        let dateStartOtherDay = try XCTUnwrap(Calendar.current.date(from: dateComponentsStartOtherDay))
        let timeEntryStartOtherDay = TimeEntry(start: dateStartOtherDay, end: self.dateEnd)
        XCTAssertEqual(timeEntryStartOtherDay.durationInSeconds(on: self.dateReference), 54000)

        let dateComponentsEndOtherDay = DateComponents(year: 2020, month: 07, day: 25)
        let dateEndOtherDay = try XCTUnwrap(Calendar.current.date(from: dateComponentsEndOtherDay))
        let timeEntryEndOtherDay = TimeEntry(start: self.dateStart, end: dateEndOtherDay)
        XCTAssertEqual(timeEntryEndOtherDay.durationInSeconds(on: self.dateReference), 37337)
    }

    func testTotalDurationFormatted() throws {
        // TBD: Should same/overlapping time entries really be added up?!
        let timeEntries = [TimeEntry(start: self.dateStart, end: self.dateEnd),
                           TimeEntry(start: self.dateStart, end: self.dateEnd)]

        XCTAssertEqual(timeEntries.totalDurationFormatted(on: self.dateReference), "02:44")
        XCTAssertEqual(timeEntries.totalDurationFormatted(on: self.dateReference, allowedUnits: [.hour, .minute]), "02:44")
        XCTAssertEqual(timeEntries.totalDurationFormatted(on: self.dateReference, allowedUnits: [.hour, .minute, .second]), "02:44:36")
    }
}
