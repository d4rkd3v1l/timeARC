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

    // MARK: TimeEntry

    func testIsRunning_Running() throws {
        let timeEntry = TimeEntry(start: self.dateStart, end: nil)
        XCTAssertTrue(timeEntry.isRunning)
    }

    func testIsRunning_NotRunning() throws {
        let timeEntry = TimeEntry(start: self.dateStart, end: self.dateEnd)
        XCTAssertFalse(timeEntry.isRunning)
    }

    func testStop() throws {
        var timeEntry = TimeEntry(start: self.dateStart, end: nil)
        XCTAssertTrue(timeEntry.isRunning)

        timeEntry.stop()
        XCTAssertFalse(timeEntry.isRunning)
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

    func testDurationInSeconds() throws {
        let timeEntry = TimeEntry(start: self.dateStart, end: self.dateEnd)
        let durationInSeconds = try XCTUnwrap(timeEntry.durationInSeconds)
        XCTAssertEqual(durationInSeconds, 4938)
    }

    func testSplittedIntoSingleDays_SingleDay() throws {
        let timeEntry = TimeEntry(start: self.dateStart, end: self.dateEnd)
        let splittedTimeEntries = timeEntry.splittedIntoSingleDays()

        XCTAssertEqual(splittedTimeEntries.count, 1)

        let splittedEntry = try XCTUnwrap(splittedTimeEntries.first)
        XCTAssertEqual(splittedEntry.id, timeEntry.id)
        XCTAssertEqual(splittedEntry.start, timeEntry.start)
        XCTAssertEqual(splittedEntry.end, timeEntry.end)
    }

    func testSplittedIntoSingleDays_SingleDay_Running() throws {
        let timeEntry = TimeEntry(start: Date(), end: nil)
        let splittedTimeEntries = timeEntry.splittedIntoSingleDays()

        XCTAssertEqual(splittedTimeEntries.count, 1)

        let splittedEntry = try XCTUnwrap(splittedTimeEntries.first)
        XCTAssertEqual(splittedEntry.id, timeEntry.id)
        XCTAssertEqual(splittedEntry.start, timeEntry.start)
        XCTAssertEqual(splittedEntry.end, nil)
    }

    func testSplittedIntoSingleDays_MultipleDays() throws {
        let dateComponentsStart = DateComponents(year: 2020, month: 07, day: 20, hour: 08, minute: 0, second: 0)
        let startDate = try XCTUnwrap(Calendar.current.date(from: dateComponentsStart))

        let dateComponentsDay2 = DateComponents(year: 2020, month: 07, day: 21)
        let day2 = try XCTUnwrap(Calendar.current.date(from: dateComponentsDay2))

        let dateComponentsEnd = DateComponents(year: 2020, month: 07, day: 22, hour: 12, minute: 0, second: 0)
        let endDate = try XCTUnwrap(Calendar.current.date(from: dateComponentsEnd))

        let timeEntry = TimeEntry(start: startDate, end: endDate)
        let splittedTimeEntries = timeEntry.splittedIntoSingleDays()

        XCTAssertEqual(splittedTimeEntries.count, 3)

        let splittedTimeEntry1 = splittedTimeEntries[0]
        XCTAssertEqual(splittedTimeEntry1.id, timeEntry.id)
        XCTAssertEqual(splittedTimeEntry1.start, startDate)
        XCTAssertEqual(splittedTimeEntry1.end, splittedTimeEntry1.start.endOfDay)

        let splittedTimeEntry2 = splittedTimeEntries[1]
        XCTAssertNotEqual(splittedTimeEntry2.id, timeEntry.id)
        XCTAssertEqual(splittedTimeEntry2.start, day2.startOfDay)
        XCTAssertEqual(splittedTimeEntry2.end, day2.endOfDay)

        let splittedTimeEntry3 = splittedTimeEntries[2]
        XCTAssertNotEqual(splittedTimeEntry3.id, timeEntry.id)
        XCTAssertEqual(splittedTimeEntry3.end, endDate)
    }

    // MARK: Dictionary extensions

    private func timeEntriesProvider() throws -> (dict: [Date: [TimeEntry]], entries: [TimeEntry]) {
        let startDateComponents1 = DateComponents(year: 2020, month: 07, day: 20, hour: 08, minute: 0, second: 0)
        let startDate1 = try XCTUnwrap(Calendar.current.date(from: startDateComponents1))

        let endDateComponents1 = DateComponents(year: 2020, month: 07, day: 20, hour: 12, minute: 0, second: 0)
        let endDate1 = try XCTUnwrap(Calendar.current.date(from: endDateComponents1))

        let startDateComponents2 = DateComponents(year: 2020, month: 07, day: 21, hour: 11, minute: 0, second: 0)
        let startDate2 = try XCTUnwrap(Calendar.current.date(from: startDateComponents2))

        let endDateComponents2 = DateComponents(year: 2020, month: 07, day: 21, hour: 15, minute: 0, second: 0)
        let endDate2 = try XCTUnwrap(Calendar.current.date(from: endDateComponents2))

        let startDateComponents3 = DateComponents(year: 2020, month: 07, day: 21, hour: 16, minute: 30, second: 0)
        let startDate3 = try XCTUnwrap(Calendar.current.date(from: startDateComponents3))

        let endDateComponents3 = DateComponents(year: 2020, month: 07, day: 21, hour: 17, minute: 0, second: 0)
        let endDate3 = try XCTUnwrap(Calendar.current.date(from: endDateComponents3))

        let timeEntry1 = TimeEntry(start: startDate1, end: endDate1)
        let timeEntry2 = TimeEntry(start: startDate2, end: endDate2)
        let timeEntry3 = TimeEntry(start: startDate3, end: endDate3)

        var timeEntries: [Date: [TimeEntry]] = [:]
        timeEntries[timeEntry1.start.startOfDay] = [timeEntry1]
        timeEntries[timeEntry2.start.startOfDay] = [timeEntry2]
        timeEntries[timeEntry3.start.startOfDay]?.append(timeEntry3)

        return (timeEntries, [timeEntry1, timeEntry2, timeEntry3])
    }

    func testForDay() throws {
        let timeEntriesProvider = try self.timeEntriesProvider()

        let timeEntriesForDay = timeEntriesProvider.dict.forDay(timeEntriesProvider.entries[0].start)
        XCTAssertEqual(timeEntriesForDay.count, 1)

        let timeEntry = try XCTUnwrap(timeEntriesForDay.first)
        XCTAssertEqual(timeEntry, timeEntriesProvider.entries[0])
    }

    func testFind() throws {
        let timeEntriesProvider = try self.timeEntriesProvider()

        let result = timeEntriesProvider.dict.find(timeEntriesProvider.entries[1])
        XCTAssertEqual(result, timeEntriesProvider.entries[1])
    }

    func testFind_Fallback() throws {
        let timeEntriesProvider = try self.timeEntriesProvider()

        var timeEntry1 = timeEntriesProvider.entries[0]
        timeEntry1.start = Date()

        let result = timeEntriesProvider.dict.find(timeEntry1)
        XCTAssertEqual(result, timeEntry1)
    }

    func testInsertValidated() throws {
        let timeEntriesProvider = try self.timeEntriesProvider()

        let startDateComponents1 = DateComponents(year: 2020, month: 07, day: 22, hour: 08, minute: 0, second: 0)
        let startDate1 = try XCTUnwrap(Calendar.current.date(from: startDateComponents1))

        let endDateComponents1 = DateComponents(year: 2020, month: 07, day: 22, hour: 12, minute: 0, second: 0)
        let endDate1 = try XCTUnwrap(Calendar.current.date(from: endDateComponents1))
        let newTimeEntry = TimeEntry(start: startDate1, end: endDate1)

        var timeEntries = timeEntriesProvider.dict
        timeEntries.insertValidated(newTimeEntry)
        XCTAssertEqual(timeEntries.values.flatMap({ $0 }).count, 4)

        let result = timeEntries.find(newTimeEntry)
        XCTAssertEqual(result, newTimeEntry)
    }

    func testUpdateValidated() throws {
        let timeEntriesProvider = try self.timeEntriesProvider()

        var updatedEntry = timeEntriesProvider.entries[0]
        updatedEntry.start = Date()
        updatedEntry.end = nil

        var timeEntries = timeEntriesProvider.dict
        timeEntries.updateValidated(updatedEntry)
        XCTAssertEqual(timeEntries.values.flatMap({ $0 }).count, 3)

        let result = timeEntries.find(updatedEntry)
        XCTAssertEqual(result, updatedEntry)
    }

    func testUpdateValidated_NotFound() throws {
        let timeEntriesProvider = try self.timeEntriesProvider()

        let updatedEntry = TimeEntry(start: Date(), end: nil)

        var timeEntries = timeEntriesProvider.dict
        timeEntries.updateValidated(updatedEntry)
        XCTAssertEqual(timeEntries.values.flatMap({ $0 }).count, 3)

        let result = timeEntries.find(updatedEntry)
        XCTAssertNil(result)
    }

    func testRemove() throws {
        let timeEntriesProvider = try self.timeEntriesProvider()

        var timeEntries = timeEntriesProvider.dict
        timeEntries.remove(timeEntriesProvider.entries[0])

        var result = timeEntries.find(timeEntriesProvider.entries[0])
        XCTAssertNil(result)

        result = timeEntries.find(timeEntriesProvider.entries[1])
        XCTAssertEqual(result, timeEntriesProvider.entries[1])
    }

    // MARK: Array extensions

    func testTotalDurationInSeconds() throws {
        let timeEntriesProvider = try self.timeEntriesProvider()
        XCTAssertEqual(timeEntriesProvider.entries.totalDurationInSeconds, 30600)
    }

    func testTotalBreaksInSeconds() throws {
        let timeEntriesProvider = try self.timeEntriesProvider()
        let timeEntriesOfDay = try XCTUnwrap(timeEntriesProvider.dict[timeEntriesProvider.entries[1].start.startOfDay])
        XCTAssertEqual(timeEntriesOfDay.totalBreaksInSeconds, 5400)
    }

    func testIsTimerRunning() throws {
        let timeEntriesProvider = try self.timeEntriesProvider()
        var timeEntries = timeEntriesProvider.entries
        XCTAssertFalse(timeEntries.isTimerRunning)

        timeEntries[2].end = nil
        XCTAssertTrue(timeEntries.isTimerRunning)
    }

    func testMergeOverlappingEntriesSimple() throws {
        let startDateComponents1 = DateComponents(year: 2020, month: 07, day: 20, hour: 08, minute: 0, second: 0)
        let startDate1 = try XCTUnwrap(Calendar.current.date(from: startDateComponents1))

        let endDateComponents1 = DateComponents(year: 2020, month: 07, day: 20, hour: 12, minute: 0, second: 0)
        let endDate1 = try XCTUnwrap(Calendar.current.date(from: endDateComponents1))

        let startDateComponents2 = DateComponents(year: 2020, month: 07, day: 20, hour: 11, minute: 0, second: 0)
        let startDate2 = try XCTUnwrap(Calendar.current.date(from: startDateComponents2))

        let endDateComponents2 = DateComponents(year: 2020, month: 07, day: 20, hour: 15, minute: 0, second: 0)
        let endDate2 = try XCTUnwrap(Calendar.current.date(from: endDateComponents2))

        let timeEntry1 = TimeEntry(start: startDate1, end: endDate1)
        let timeEntry2 = TimeEntry(start: startDate2, end: endDate2)
        let entries = [timeEntry1, timeEntry2]
        let mergedEntry = try XCTUnwrap(entries.mergedOverlappingEntries().first)

        XCTAssertEqual(mergedEntry.start, startDate1)
        XCTAssertEqual(mergedEntry.end, endDate2)
    }

    func testMergeOverlappingEntriesNoMerge() throws {
        let dateComponents1 = DateComponents(year: 2020, month: 07, day: 20, hour: 08, minute: 0, second: 0)
        let date1 = try XCTUnwrap(Calendar.current.date(from: dateComponents1))

        let dateComponents2 = DateComponents(year: 2020, month: 07, day: 20, hour: 12, minute: 0, second: 0)
        let date2 = try XCTUnwrap(Calendar.current.date(from: dateComponents2))

        let dateComponents3 = DateComponents(year: 2020, month: 07, day: 20, hour: 13, minute: 0, second: 0)
        let date3 = try XCTUnwrap(Calendar.current.date(from: dateComponents3))

        let dateComponents4 = DateComponents(year: 2020, month: 07, day: 20, hour: 15, minute: 0, second: 0)
        let date4 = try XCTUnwrap(Calendar.current.date(from: dateComponents4))

        let timeEntry1 = TimeEntry(start: date1, end: date2)
        let timeEntry2 = TimeEntry(start: date3, end: date4)
        let entries = [timeEntry1, timeEntry2]
        let mergedEntries = entries.mergedOverlappingEntries()

        XCTAssertEqual(mergedEntries[0], timeEntry1)
        XCTAssertEqual(mergedEntries[1], timeEntry2)
    }

    func testMergeOverlappingEntriesContains() throws {
        let dateComponents1 = DateComponents(year: 2020, month: 07, day: 20, hour: 08, minute: 0, second: 0)
        let date1 = try XCTUnwrap(Calendar.current.date(from: dateComponents1))

        let dateComponents2 = DateComponents(year: 2020, month: 07, day: 20, hour: 12, minute: 0, second: 0)
        let date2 = try XCTUnwrap(Calendar.current.date(from: dateComponents2))

        let dateComponents3 = DateComponents(year: 2020, month: 07, day: 20, hour: 09, minute: 0, second: 0)
        let date3 = try XCTUnwrap(Calendar.current.date(from: dateComponents3))

        let dateComponents4 = DateComponents(year: 2020, month: 07, day: 20, hour: 10, minute: 0, second: 0)
        let date4 = try XCTUnwrap(Calendar.current.date(from: dateComponents4))

        let timeEntry1 = TimeEntry(start: date1, end: date2)
        let timeEntry2 = TimeEntry(start: date3, end: date4)
        let entries = [timeEntry1, timeEntry2]
        let mergedEntries = entries.mergedOverlappingEntries()
        XCTAssertEqual(mergedEntries.count, 1)

        let mergedEntry = try XCTUnwrap(mergedEntries.first)
        XCTAssertEqual(mergedEntry.start, date1)
        XCTAssertEqual(mergedEntry.end, date2)
    }

    // MARK: Int extensions

    func testFormatted() throws {
        XCTAssertEqual(123456.formatted(), "34:17")
    }
}