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

    func testInsertAbsenceEntry() throws {
        var state = TimeState()
        let absenceEntry = AbsenceEntry(type: .dummy, start: Day(), end: Day().addingDays(2))

        let action = AddAbsenceEntry(absenceEntry: absenceEntry)
        state = timeReducer(state: state, action: action)

        XCTAssertEqual(state.absenceEntries, [absenceEntry])
        XCTAssertTrue(state.timeEntries.keys.contains(Day()))
        XCTAssertTrue(state.timeEntries.keys.contains(Day().addingDays(1)))
        XCTAssertTrue(state.timeEntries.keys.contains(Day().addingDays(2)))
    }

    func testUpdateAbsenceEntry() throws {
        var state = TimeState()
        let absenceEntry = AbsenceEntry(type: .dummy, start: Day(), end: Day().addingDays(2))
        state.absenceEntries.append(absenceEntry)

        var updatedAbsenceEntry = absenceEntry
        updatedAbsenceEntry.update(type: .dummy, start: Day().addingDays(1), end: Day().addingDays(3))

        let action = UpdateAbsenceEntry(absenceEntry: absenceEntry)
        state = timeReducer(state: state, action: action)

        XCTAssertEqual(state.absenceEntries, [updatedAbsenceEntry])
    }

    func testRemoveAbsenceEntry() throws {
        var state = TimeState()
        let absenceEntry = AbsenceEntry(type: .dummy, start: Day(), end: Day().addingDays(2))

        let addAction = AddAbsenceEntry(absenceEntry: absenceEntry)
        state = timeReducer(state: state, action: addAction)

        XCTAssertEqual(state.absenceEntries, [absenceEntry])
        XCTAssertTrue(state.timeEntries.keys.contains(Day()))
        XCTAssertTrue(state.timeEntries.keys.contains(Day().addingDays(1)))
        XCTAssertTrue(state.timeEntries.keys.contains(Day().addingDays(2)))

        let removeAction = DeleteAbsenceEntry(absenceEntry: absenceEntry, onlyForDay: nil)
        state = timeReducer(state: state, action: removeAction)

        XCTAssertTrue(state.absenceEntries.isEmpty)
        XCTAssertFalse(state.timeEntries.keys.contains(Day()))
        XCTAssertFalse(state.timeEntries.keys.contains(Day().addingDays(1)))
        XCTAssertFalse(state.timeEntries.keys.contains(Day().addingDays(2)))
    }

    func testRemoveAbsenceEntry_OnlyFor_FirstDay() throws {
        var state = TimeState()
        let absenceEntry = AbsenceEntry(type: .dummy, start: Day(), end: Day().addingDays(2))

        let addAction = AddAbsenceEntry(absenceEntry: absenceEntry)
        state = timeReducer(state: state, action: addAction)

        XCTAssertEqual(state.absenceEntries, [absenceEntry])
        XCTAssertTrue(state.timeEntries.keys.contains(Day()))
        XCTAssertTrue(state.timeEntries.keys.contains(Day().addingDays(1)))
        XCTAssertTrue(state.timeEntries.keys.contains(Day().addingDays(2)))

        let removeAction = DeleteAbsenceEntry(absenceEntry: absenceEntry, onlyForDay: Day())
        state = timeReducer(state: state, action: removeAction)

        XCTAssertEqual(state.absenceEntries.count, 1)
        XCTAssertFalse(state.timeEntries.keys.contains(Day()))
        XCTAssertTrue(state.timeEntries.keys.contains(Day().addingDays(1)))
        XCTAssertTrue(state.timeEntries.keys.contains(Day().addingDays(2)))
    }

    func testRemoveAbsenceEntry_OnlyFor_MiddleDay() throws {
        var state = TimeState()
        let absenceEntry = AbsenceEntry(type: .dummy, start: Day(), end: Day().addingDays(2))

        let addAction = AddAbsenceEntry(absenceEntry: absenceEntry)
        state = timeReducer(state: state, action: addAction)

        XCTAssertEqual(state.absenceEntries, [absenceEntry])
        XCTAssertTrue(state.timeEntries.keys.contains(Day()))
        XCTAssertTrue(state.timeEntries.keys.contains(Day().addingDays(1)))
        XCTAssertTrue(state.timeEntries.keys.contains(Day().addingDays(2)))

        let removeAction = DeleteAbsenceEntry(absenceEntry: absenceEntry, onlyForDay: Day().addingDays(1))
        state = timeReducer(state: state, action: removeAction)

        XCTAssertEqual(state.absenceEntries.count, 2)
        XCTAssertTrue(state.timeEntries.keys.contains(Day()))
        XCTAssertFalse(state.timeEntries.keys.contains(Day().addingDays(1)))
        XCTAssertTrue(state.timeEntries.keys.contains(Day().addingDays(2)))
    }

    func testRemoveAbsenceEntry_OnlyFor_LastDay() throws {
        var state = TimeState()
        let absenceEntry = AbsenceEntry(type: .dummy, start: Day(), end: Day().addingDays(2))

        let addAction = AddAbsenceEntry(absenceEntry: absenceEntry)
        state = timeReducer(state: state, action: addAction)

        XCTAssertEqual(state.absenceEntries, [absenceEntry])
        XCTAssertTrue(state.timeEntries.keys.contains(Day()))
        XCTAssertTrue(state.timeEntries.keys.contains(Day().addingDays(1)))
        XCTAssertTrue(state.timeEntries.keys.contains(Day().addingDays(2)))

        let removeAction = DeleteAbsenceEntry(absenceEntry: absenceEntry, onlyForDay: Day().addingDays(2))
        state = timeReducer(state: state, action: removeAction)

        XCTAssertEqual(state.absenceEntries.count, 1)
        XCTAssertTrue(state.timeEntries.keys.contains(Day()))
        XCTAssertTrue(state.timeEntries.keys.contains(Day().addingDays(1)))
        XCTAssertFalse(state.timeEntries.keys.contains(Day().addingDays(2)))
    }

    func testRemoveAbsenceEntry_OnlyFor_SingleDay() throws {
        var state = TimeState()
        let absenceEntry = AbsenceEntry(type: .dummy, start: Day(), end: Day())

        let addAction = AddAbsenceEntry(absenceEntry: absenceEntry)
        state = timeReducer(state: state, action: addAction)

        XCTAssertEqual(state.absenceEntries, [absenceEntry])
        XCTAssertTrue(state.timeEntries.keys.contains(Day()))

        let removeAction = DeleteAbsenceEntry(absenceEntry: absenceEntry, onlyForDay: Day())
        state = timeReducer(state: state, action: removeAction)

        XCTAssertTrue(state.absenceEntries.isEmpty)
        XCTAssertFalse(state.timeEntries.keys.contains(Day()))
    }

    func testRemoveAbsenceEntry_OnlyFor_InvalidDay() throws {
        var state = TimeState()
        let absenceEntry = AbsenceEntry(type: .dummy, start: Day(), end: Day())

        let addAction = AddAbsenceEntry(absenceEntry: absenceEntry)
        state = timeReducer(state: state, action: addAction)

        XCTAssertEqual(state.absenceEntries, [absenceEntry])
        XCTAssertTrue(state.timeEntries.keys.contains(Day()))

        let removeAction = DeleteAbsenceEntry(absenceEntry: absenceEntry, onlyForDay: Day().addingDays(1))
        state = timeReducer(state: state, action: removeAction)

        XCTAssertEqual(state.absenceEntries, [absenceEntry])
        XCTAssertTrue(state.timeEntries.keys.contains(Day()))
    }

    func testSyncTimeEntriesFromWatch_Update() throws {
        var state = TimeState()
        let startDate1 = try Date(year: 2020, month: 10, day: 3, hour: 21, minute: 41, second: 16)
        let endDate1 = try Date(year: 2020, month: 10, day: 3, hour: 21, minute: 48, second: 41)
        let timeEntry1 = TimeEntry(start: startDate1, end: endDate1)

        let startDate2 = try Date(year: 2020, month: 10, day: 3, hour: 21, minute: 52, second: 5)
        var timeEntry2 = TimeEntry(start: startDate2, end: nil)

        state.timeEntries[startDate1.day] = [timeEntry1, timeEntry2]
        var timeEntriesOfDay = try XCTUnwrap(state.timeEntries[startDate1.day])
        XCTAssertEqual(timeEntriesOfDay.count, 2)

        let endDate2 = try Date(year: 2020, month: 10, day: 3, hour: 21, minute: 52, second: 13)
        timeEntry2.end = endDate2
        let action = SyncTimeEntriesFromWatch(timeEntries: [timeEntry1, timeEntry2])
        state = timeReducer(state: state, action: action)
        timeEntriesOfDay = try XCTUnwrap(state.timeEntries[startDate1.day])
        XCTAssertEqual(timeEntriesOfDay.count, 2)
        XCTAssertTrue(state.didSyncWatchData)
    }

    func testSyncTimeEntriesFromWatch_Insert() throws {
        var state = TimeState()
        let startDate1 = try Date(year: 2020, month: 10, day: 3, hour: 21, minute: 41, second: 16)
        let endDate1 = try Date(year: 2020, month: 10, day: 3, hour: 21, minute: 48, second: 41)
        let timeEntry1 = TimeEntry(start: startDate1, end: endDate1)

        state.timeEntries[startDate1.day] = [timeEntry1]
        var timeEntriesOfDay = try XCTUnwrap(state.timeEntries[startDate1.day])
        XCTAssertEqual(timeEntriesOfDay.count, 1)

        let startDate2 = try Date(year: 2020, month: 10, day: 3, hour: 21, minute: 52, second: 5)
        let endDate2 = try Date(year: 2020, month: 10, day: 3, hour: 21, minute: 52, second: 13)
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
