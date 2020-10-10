//
//  TimerReducerTests.swift
//  Tests iOS
//
//  Created by d4Rk on 20.07.20.
//

import XCTest
@testable import timetracker

class TimeReducerTests: XCTestCase {
    func testToggleTimerStart() throws {
        var state = TimeState()
        XCTAssertTrue(state.timeEntries.isEmpty)

        let action = ToggleTimer()
        state = timeReducer(state: state, action: action)
        XCTAssertEqual(state.timeEntries.count, 1)
        let timeEntriesOfDay = try XCTUnwrap(state.timeEntries[Day()])
        XCTAssertEqual(timeEntriesOfDay.count, 1)

        let timeEntry = try XCTUnwrap(timeEntriesOfDay.first)
        XCTAssertTrue(timeEntry.isRunning)
    }

    func testToggleTimerStop() throws {
        var state = TimeState()
        let date = Date()
        let initialTimeEntry = TimeEntry(start: date, end: nil)
        state.timeEntries[date.day] = [initialTimeEntry]
        XCTAssertEqual(state.timeEntries.count, 1)

        let action = ToggleTimer()
        state = timeReducer(state: state, action: action)

        XCTAssertEqual(state.timeEntries.count, 1)
        let timeEntriesOfDay = try XCTUnwrap(state.timeEntries[Day()])
        XCTAssertEqual(timeEntriesOfDay.count, 1)

        let timeEntry = try XCTUnwrap(timeEntriesOfDay.first)
        XCTAssertFalse(timeEntry.isRunning)
    }

    func testAddTimeEntry() throws {
        var state = TimeState()
        let initialTimeEntry = TimeEntry(start: Date(timeIntervalSinceNow: -60), end: Date())
        let action = AddTimeEntry(timeEntry: initialTimeEntry)
        state = timeReducer(state: state, action: action)

        XCTAssertEqual(state.timeEntries.count, 1)

        let timeEntry = try XCTUnwrap(state.timeEntries[Day()]?.first)
        XCTAssertEqual(timeEntry, initialTimeEntry)
    }

    func testUpdateTimeEntry() throws {
        var state = TimeState()
        let date = Date()
        let initialTimeEntry = TimeEntry(start: date, end: nil)
        state.timeEntries[date.day] = [initialTimeEntry]
        XCTAssertEqual(state.timeEntries.count, 1)

        var updatedTimeEntry = initialTimeEntry
        updatedTimeEntry.end = date
        let action = UpdateTimeEntry(timeEntry: updatedTimeEntry)
        state = timeReducer(state: state, action: action)

        let timeEntry = try XCTUnwrap(state.timeEntries[Day()]?.first)

        XCTAssertEqual(timeEntry, updatedTimeEntry)
    }

    func testDeleteTimeEntry() throws {
        var state = TimeState()
        let date = Date()
        let initialTimeEntry = TimeEntry(start: date, end: nil)
        state.timeEntries[date.day] = [initialTimeEntry]
        XCTAssertEqual(state.timeEntries.count, 1)

        let action = DeleteTimeEntry(timeEntry: initialTimeEntry)
        state = timeReducer(state: state, action: action)

        XCTAssertTrue(state.timeEntries.isEmpty)
    }

    func testSyncTimeEntriesFromWatch_Update() throws {
        var state = TimeState()
        let startDateComponents1 = DateComponents(year: 2020, month: 10, day: 3, hour: 21, minute: 41, second: 16)
        let startDate1 = try XCTUnwrap(Calendar.current.date(from: startDateComponents1))
        let endDateComponents1 = DateComponents(year: 2020, month: 10, day: 3, hour: 21, minute: 48, second: 41)
        let endDate1 = try XCTUnwrap(Calendar.current.date(from: endDateComponents1))
        let timeEntry1 = TimeEntry(start: startDate1, end: endDate1)

        let startDateComponents2 = DateComponents(year: 2020, month: 10, day: 3, hour: 21, minute: 52, second: 5)
        let startDate2 = try XCTUnwrap(Calendar.current.date(from: startDateComponents2))
        var timeEntry2 = TimeEntry(start: startDate2, end: nil)

        state.timeEntries[startDate1.day] = [timeEntry1, timeEntry2]
        var timeEntriesOfDay = try XCTUnwrap(state.timeEntries[startDate1.day])
        XCTAssertEqual(timeEntriesOfDay.count, 2)

        let endDateComponents2 = DateComponents(year: 2020, month: 10, day: 3, hour: 21, minute: 52, second: 13)
        let endDate2 = try XCTUnwrap(Calendar.current.date(from: endDateComponents2))
        timeEntry2.end = endDate2
        let action = SyncTimeEntriesFromWatch(timeEntries: [timeEntry1, timeEntry2])
        state = timeReducer(state: state, action: action)
        timeEntriesOfDay = try XCTUnwrap(state.timeEntries[startDate1.day])
        XCTAssertEqual(timeEntriesOfDay.count, 2)
        XCTAssertTrue(state.didSyncWatchData)
    }

    func testSyncTimeEntriesFromWatch_Insert() throws {
        var state = TimeState()
        let startDateComponents1 = DateComponents(year: 2020, month: 10, day: 3, hour: 21, minute: 41, second: 16)
        let startDate1 = try XCTUnwrap(Calendar.current.date(from: startDateComponents1))
        let endDateComponents1 = DateComponents(year: 2020, month: 10, day: 3, hour: 21, minute: 48, second: 41)
        let endDate1 = try XCTUnwrap(Calendar.current.date(from: endDateComponents1))
        let timeEntry1 = TimeEntry(start: startDate1, end: endDate1)

        state.timeEntries[startDate1.day] = [timeEntry1]
        var timeEntriesOfDay = try XCTUnwrap(state.timeEntries[startDate1.day])
        XCTAssertEqual(timeEntriesOfDay.count, 1)

        let startDateComponents2 = DateComponents(year: 2020, month: 10, day: 3, hour: 21, minute: 52, second: 5)
        let startDate2 = try XCTUnwrap(Calendar.current.date(from: startDateComponents2))
        let endDateComponents2 = DateComponents(year: 2020, month: 10, day: 3, hour: 21, minute: 52, second: 13)
        let endDate2 = try XCTUnwrap(Calendar.current.date(from: endDateComponents2))
        let timeEntry2 = TimeEntry(start: startDate2, end: endDate2)

        let action = SyncTimeEntriesFromWatch(timeEntries: [timeEntry1, timeEntry2])
        state = timeReducer(state: state, action: action)
        timeEntriesOfDay = try XCTUnwrap(state.timeEntries[startDate1.day])
        XCTAssertEqual(timeEntriesOfDay.count, 2)
        XCTAssertTrue(state.didSyncWatchData)
    }

    func testRequestWatchData() throws {
        var state = TimeState()
        state.didSyncWatchData = true
        XCTAssertTrue(state.didSyncWatchData)

        let action = RequestWatchData()
        state = timeReducer(state: state, action: action)
        XCTAssertFalse(state.didSyncWatchData)
    }

    func testChangeTimerDisplayMode() throws {
        var state = TimeState()
        XCTAssertEqual(state.displayMode, .countUp)

        let action = ChangeTimerDisplayMode(displayMode: .endOfWorkingDay)
        state = timeReducer(state: state, action: action)
        XCTAssertEqual(state.displayMode, .endOfWorkingDay)
    }
}
