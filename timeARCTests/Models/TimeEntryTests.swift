//
//  TimeEntryTests.swift
//  timeARCTests
//
//  Created by d4Rk on 20.07.20.
//

import XCTest
@testable import timeARC
import SwiftUI

class TimeEntryTests: XCTestCase {
    var dateStart: Date!
    var dateEnd: Date!
    var dateReference: Date!

    override func setUpWithError() throws {
        self.dateStart = try Date(year: 2020, month: 07, day: 20, hour: 13, minute: 37, second: 42)
        self.dateEnd = try Date(year: 2020, month: 07, day: 20, hour: 15, minute: 00, second: 00)
        self.dateReference = try Date(year: 2020, month: 07, day: 20)
    }

    private func timeEntriesProvider() throws -> (dict: [Day: [TimeEntry]], entries: [TimeEntry]) {
        let startDate1 = try Date(year: 2020, month: 07, day: 20, hour: 08, minute: 0, second: 0)
        let endDate1 = try Date(year: 2020, month: 07, day: 20, hour: 12, minute: 0, second: 0)

        let startDate2 = try Date(year: 2020, month: 07, day: 21, hour: 11, minute: 0, second: 0)
        let endDate2 = try Date(year: 2020, month: 07, day: 21, hour: 15, minute: 0, second: 0)

        let startDate3 = try Date(year: 2020, month: 07, day: 21, hour: 16, minute: 30, second: 0)
        let endDate3 = try Date(year: 2020, month: 07, day: 21, hour: 17, minute: 0, second: 0)

        let timeEntry1 = TimeEntry(start: startDate1, end: endDate1)
        let timeEntry2 = TimeEntry(start: startDate2, end: endDate2)
        let timeEntry3 = TimeEntry(start: startDate3, end: endDate3)

        var timeEntries: [Day: [TimeEntry]] = [:]
        timeEntries[timeEntry1.start.day] = [timeEntry1]
        timeEntries[timeEntry2.start.day] = [timeEntry2]
        timeEntries[timeEntry3.start.day]?.append(timeEntry3)

        return (timeEntries, [timeEntry1, timeEntry2, timeEntry3])
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
        XCTAssertEqual(durationInSeconds, 4_938)
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
        let startDate = try Date(year: 2020, month: 07, day: 20, hour: 08, minute: 0, second: 0)
        let day2 = try Date(year: 2020, month: 07, day: 21)
        let endDate = try Date(year: 2020, month: 07, day: 22, hour: 12, minute: 0, second: 0)

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

    func testDictForDay() throws {
        let timeEntriesProvider = try self.timeEntriesProvider()

        let timeEntriesForDay = timeEntriesProvider.dict.forDay(timeEntriesProvider.entries[0].start.day)
        XCTAssertEqual(timeEntriesForDay.count, 1)

        let timeEntry = try XCTUnwrap(timeEntriesForDay.first)
        XCTAssertEqual(timeEntry, timeEntriesProvider.entries[0])
    }

    func testDictFind() throws {
        let timeEntriesProvider = try self.timeEntriesProvider()

        let result = timeEntriesProvider.dict.find(timeEntriesProvider.entries[1])
        XCTAssertEqual(result, timeEntriesProvider.entries[1])
    }

    func testDictFind_Fallback() throws {
        let timeEntriesProvider = try self.timeEntriesProvider()

        var timeEntry1 = timeEntriesProvider.entries[0]
        timeEntry1.start = Date()

        let result = timeEntriesProvider.dict.find(timeEntry1)
        XCTAssertEqual(result?.id, timeEntry1.id)
    }

    func testDictIsTimerRunning() throws {
        let timeEntriesProvider = try self.timeEntriesProvider()
        var dict = timeEntriesProvider.dict
        dict[Day()] = [TimeEntry(start: Date(), end: nil)]

        XCTAssertEqual(dict.isTimerRunning, true)
    }

    func testDictIsTimerRunning_Not() throws {
        let timeEntriesProvider = try self.timeEntriesProvider()
        XCTAssertEqual(timeEntriesProvider.dict.isTimerRunning, false)
    }

    // MARK: Statistics

    func timeEntries() throws -> [Day: [TimeEntry]] {
        let startDate1 = try Date(year: 2020, month: 10, day: 26, hour: 8, minute: 0, second: 0)
        let endDate1 = try Date(year: 2020, month: 10, day: 26, hour: 12, minute: 12, second: 13)

        let startDate2 = try Date(year: 2020, month: 10, day: 26, hour: 13, minute: 0, second: 0)
        let endDate2 = try Date(year: 2020, month: 10, day: 26, hour: 17, minute: 56, second: 21)

        let startDate3 = try Date(year: 2020, month: 10, day: 28, hour: 11, minute: 0, second: 0)
        let endDate3 = try Date(year: 2020, month: 10, day: 28, hour: 15, minute: 14, second: 15)

        let startDate4 = try Date(year: 2020, month: 10, day: 28, hour: 16, minute: 0, second: 0)
        let endDate4 = try Date(year: 2020, month: 10, day: 28, hour: 17, minute: 45, second: 34)

        let startDate5 = try Date(year: 2020, month: 10, day: 31, hour: 9, minute: 0, second: 0)
        let endDate5 = try Date(year: 2020, month: 10, day: 31, hour: 13, minute: 12, second: 23)

        let timeEntry1 = TimeEntry(start: startDate1, end: endDate1)
        let timeEntry2 = TimeEntry(start: startDate2, end: endDate2)
        let timeEntry3 = TimeEntry(start: startDate3, end: endDate3)
        let timeEntry4 = TimeEntry(start: startDate4, end: endDate4)
        let timeEntry5 = TimeEntry(start: startDate5, end: endDate5)

        return [startDate1.day: [timeEntry1, timeEntry2],
                startDate3.day: [timeEntry3, timeEntry4],
                startDate5.day: [timeEntry5]]
    }

    func workingDays() throws -> [Day] {
        let startDate = try Date(year: 2020, month: 10, day: 26)
        let endDate = try Date(year: 2020, month: 11, day: 1)

        let workingWeekDays: [WeekDay] = [.monday,
                                          .tuesday,
                                          .wednesday,
                                          .thursday,
                                          .friday]

        return workingWeekDays.workingDays(startDate: startDate, endDate: endDate)
    }

    func testTimeEntries() throws {
        let timeEntries = try self.timeEntries()
        let fromDate = try Date(year: 2020, month: 10, day: 25)
        let toDate = try Date(year: 2020, month: 10, day: 30)

        let result = timeEntries.timeEntries(from: fromDate, to: toDate)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.values.flatMap { $0 }.count, 4)
    }

    func testAverageDuration() throws {
        let timeEntries = try self.timeEntries()

        let averageDuration = timeEntries.averageDuration()
        XCTAssertEqual(averageDuration, 23_215)
    }

    func testTotalDuration() throws {
        let timeEntries = try self.timeEntries()

        let totalDuration = timeEntries.totalDuration()
        XCTAssertEqual(totalDuration, 69_646)
    }

    func testAverageWorkingHoursStartDate() throws {
        let timeEntries = try self.timeEntries()

        let averageWorkingHoursStartDate = timeEntries.averageWorkingHoursStartDate()
        XCTAssertEqual(averageWorkingHoursStartDate, Date(timeInterval: 33_600, since: Date().startOfDay))
    }

    func testAverageWorkingHoursEndDate() throws {
        let timeEntries = try self.timeEntries()

        let averageWorkingHoursEndDate = timeEntries.averageWorkingHoursEndDate()
        XCTAssertEqual(averageWorkingHoursEndDate, Date(timeInterval: 58_686, since: Date().startOfDay))
    }

    func testAverageBreaksDuration() throws {
        let timeEntries = try self.timeEntries()

        let averageBreaksDuration = timeEntries.averageBreaksDuration()
        XCTAssertEqual(averageBreaksDuration, 1_870)
    }

    func testTotalBreaksDuration() throws {
        let timeEntries = try self.timeEntries()

        let totalBreaksDuration = timeEntries.totalBreaksDuration()
        XCTAssertEqual(totalBreaksDuration, 5_612)
    }

    func testAverageOvertimeDuration() throws {
        let timeEntries = try self.timeEntries()

        let averageOvertimeDuration = timeEntries.averageOvertimeDuration(workingDuration: 28_800)
        XCTAssertEqual(averageOvertimeDuration, -5_585)
    }

    func testTotalOvertimeDuration() throws {
        let timeEntries = try self.timeEntries()
        let workingDays = try self.workingDays()

        let totalOvertimeDuration = timeEntries.totalOvertimeDuration(workingDays: workingDays, workingDuration: 28_800, absenceEntries: [])
        XCTAssertEqual(totalOvertimeDuration, -74_354)
    }


    // MARK: Array extensions

    func testArrayTotalDurationInSeconds() throws {
        let timeEntriesProvider = try self.timeEntriesProvider()
        XCTAssertEqual(timeEntriesProvider.entries.totalDurationInSeconds, 30_600)
    }

    func testArrayTotalBreaksInSeconds() throws {
        let timeEntriesProvider = try self.timeEntriesProvider()
        let timeEntriesOfDay = try XCTUnwrap(timeEntriesProvider.dict[timeEntriesProvider.entries[1].start.day])
        XCTAssertEqual(timeEntriesOfDay.totalBreaksInSeconds, 5_400)
    }

    func testArrayIsTimerRunning() throws {
        let timeEntriesProvider = try self.timeEntriesProvider()
        var timeEntries = timeEntriesProvider.entries
        XCTAssertFalse(timeEntries.isTimerRunning)

        timeEntries[2].end = nil
        XCTAssertTrue(timeEntries.isTimerRunning)
    }

    func testArrayMergeOverlappingEntries_Simple() throws {
        let startDate1 = try Date(year: 2020, month: 07, day: 20, hour: 08, minute: 0, second: 0)
        let endDate1 = try Date(year: 2020, month: 07, day: 20, hour: 12, minute: 0, second: 0)

        let startDate2 = try Date(year: 2020, month: 07, day: 20, hour: 11, minute: 0, second: 0)
        let endDate2 = try Date(year: 2020, month: 07, day: 20, hour: 15, minute: 0, second: 0)

        let timeEntry1 = TimeEntry(start: startDate1, end: endDate1)
        let timeEntry2 = TimeEntry(start: startDate2, end: endDate2)
        let entries = [timeEntry1, timeEntry2]
        let mergedEntry = try XCTUnwrap(entries.mergedOverlappingEntries().first)

        XCTAssertEqual(mergedEntry.start, startDate1)
        XCTAssertEqual(mergedEntry.end, endDate2)
    }

    func testArrayMergeOverlappingEntries_Simple_IsRunning() throws {
        let startDate1 = try Date(year: 2020, month: 07, day: 20, hour: 08, minute: 0, second: 0)
        let endDate1 = try Date(year: 2020, month: 07, day: 20, hour: 12, minute: 0, second: 0)
        let startDate2 = try Date(year: 2020, month: 07, day: 20, hour: 11, minute: 0, second: 0)

        let timeEntry1 = TimeEntry(start: startDate1, end: endDate1)
        let timeEntry2 = TimeEntry(start: startDate2, end: nil)
        let entries = [timeEntry1, timeEntry2]
        let mergedEntry = try XCTUnwrap(entries.mergedOverlappingEntries().first)

        XCTAssertEqual(mergedEntry.start, startDate1)
        XCTAssertEqual(mergedEntry.end, nil)
    }

    func testArrayMergeOverlappingEntries_NoMerge() throws {
        let date1 = try Date(year: 2020, month: 07, day: 20, hour: 08, minute: 0, second: 0)
        let date2 = try Date(year: 2020, month: 07, day: 20, hour: 12, minute: 0, second: 0)
        let date3 = try Date(year: 2020, month: 07, day: 20, hour: 13, minute: 0, second: 0)
        let date4 = try Date(year: 2020, month: 07, day: 20, hour: 15, minute: 0, second: 0)

        let timeEntry1 = TimeEntry(start: date1, end: date2)
        let timeEntry2 = TimeEntry(start: date3, end: date4)
        let entries = [timeEntry1, timeEntry2]
        let mergedEntries = entries.mergedOverlappingEntries()

        XCTAssertEqual(mergedEntries[0], timeEntry1)
        XCTAssertEqual(mergedEntries[1], timeEntry2)
    }

    func testArrayMergeOverlappingEntries_Contains() throws {
        let date1 = try Date(year: 2020, month: 07, day: 20, hour: 08, minute: 0, second: 0)
        let date2 = try Date(year: 2020, month: 07, day: 20, hour: 12, minute: 0, second: 0)
        let date3 = try Date(year: 2020, month: 07, day: 20, hour: 09, minute: 0, second: 0)
        let date4 = try Date(year: 2020, month: 07, day: 20, hour: 10, minute: 0, second: 0)

        let timeEntry1 = TimeEntry(start: date1, end: date2)
        let timeEntry2 = TimeEntry(start: date3, end: date4)
        let entries = [timeEntry1, timeEntry2]
        let mergedEntries = entries.mergedOverlappingEntries()
        XCTAssertEqual(mergedEntries.count, 1)

        let mergedEntry = try XCTUnwrap(mergedEntries.first)
        XCTAssertEqual(mergedEntry.start, date1)
        XCTAssertEqual(mergedEntry.end, date2)
    }

    func testArrayGetBreak() throws {
        let timeEntriesProvider = try self.timeEntriesProvider()

        let breakBetween1And2 = timeEntriesProvider.entries.getBreak(between: 1, and: 2)
        XCTAssertEqual(breakBetween1And2, 5_400)
    }

    // MARK: Int extensions

    func testFormatted() throws {
        XCTAssertEqual(123_456.formatted(), "34:17")
    }

    func testFormattedFull() throws {
        if Locale.current.identifier == "de_DE" {
            XCTAssertEqual(123_456.formattedFull(), "34 Stunden und 17 Minuten")
        } else if Locale.current.identifier == "en_US" {
            XCTAssertEqual(123_456.formattedFull(), "34 hours, 17 minutes")
        } else {
            throw XCTSkip("Invalid locale for this test.")
        }
    }
}
