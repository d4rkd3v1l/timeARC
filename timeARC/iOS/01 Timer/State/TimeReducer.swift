//
//  TimerReducer.swift
//  timeARC
//
//  Created by d4Rk on 20.07.20.
//

import Foundation
import SwiftUIFlux

func timeReducer(state: TimeState, action: Action) -> TimeState {
    var state = state

    switch action {
    case _ as ToggleTimer:
        var didStopTimer = false
        let timeEntriesForDay = state.timeEntries.forDay(Day())
        if var runningTimeEntry = timeEntriesForDay.first(where: { $0.isRunning }) {
            runningTimeEntry.stop()
            updateTimeEntryValidated(runningTimeEntry, &state)
            didStopTimer = true
        }

        if !didStopTimer {
            insertTimeEntryValidated(TimeEntry(), &state)
        }

    case let action as AddTimeEntry:
        insertTimeEntryValidated(action.timeEntry, &state)

    case let action as UpdateTimeEntry:
        updateTimeEntryValidated(action.timeEntry, &state)

    case let action as DeleteTimeEntry:
        removeTimeEntry(action.timeEntry, &state)

    case let action as DeleteTimeEntryById:
        let fakeTimeEntry = TimeEntry(id: action.id, start: Date())
        guard let timeEntry = state.timeEntries.find(fakeTimeEntry) else { break }
        removeTimeEntry(timeEntry, &state)

    case let action as AddAbsenceEntry:
        insertAbsenceEntry(action.absenceEntry, &state)

    case let action as UpdateAbsenceEntry:
        updateAbsenceEntry(action.absenceEntry, &state)

    case let action as DeleteAbsenceEntry:
        removeAbsenceEntry(action.absenceEntry, onlyFor: action.onlyForDay, &state)

    case let action as DeleteAbsenceEntryById:
        let fakeAbsenceEntry = AbsenceEntry(id: action.id, type: .dummy, start: Day(), end: Day())
        removeAbsenceEntry(fakeAbsenceEntry, onlyFor: nil, &state)

    case let action as SyncTimeEntriesFromWatch:
        action.timeEntries.forEach { timeEntry in
            if state.timeEntries.find(timeEntry) != nil {
                updateTimeEntryValidated(timeEntry, &state)
            } else {
                insertTimeEntryValidated(timeEntry, &state)
            }
        }
        state.displayMode = action.displayMode
        state.didSyncWatchData = true

    case _ as RequestWatchData:
        state.didSyncWatchData = false

    case let action as ChangeTimerDisplayMode:
        state.displayMode = action.displayMode

    default:
        break
    }

    return state
}

/// - Does automatically split `TimeEntry`s into single days, that would otherwise span multiple days
/// - `TimeEntry`s for each day are sorted ascending by their `start` date
private func insertTimeEntryValidated(_ timeEntry: TimeEntry, _ state: inout TimeState) {
    timeEntry.splittedIntoSingleDays().forEach { timeEntry in
        let day = timeEntry.start.day
        if !state.timeEntries.keys.contains(day) {
            state.timeEntries[day] = []
        }

        state.timeEntries[day]?.append(timeEntry)
        state.timeEntries[day] = state.timeEntries[day]?.mergedOverlappingEntries()
    }
}

private func updateTimeEntryValidated(_ timeEntry: TimeEntry, _ state: inout TimeState) {
    guard let oldTimeEntry = state.timeEntries.find(timeEntry),
          timeEntry.lastModified > oldTimeEntry.lastModified else { return }

    var newTimeEntry = oldTimeEntry
    newTimeEntry.start = timeEntry.start
    newTimeEntry.end = timeEntry.end

    removeTimeEntry(oldTimeEntry, &state)
    insertTimeEntryValidated(newTimeEntry, &state)
}

private func removeTimeEntry(_ timeEntry: TimeEntry, _ state: inout TimeState) {
    let day = timeEntry.start.day
    state.timeEntries[day]?.removeAll(where: { $0.id == timeEntry.id })

    if state.timeEntries[day]?.isEmpty ?? false {
        state.timeEntries.removeValue(forKey: day)
    }
}

private func insertAbsenceEntry(_ absenceEntry: AbsenceEntry, _ state: inout TimeState) {
    state.absenceEntries.append(absenceEntry)
}

private func updateAbsenceEntry(_ absenceEntry: AbsenceEntry, _ state: inout TimeState) {
    guard let oldAbsenceEntry = state.absenceEntries.first(where: { $0.id == absenceEntry.id }) else { return }

    var newAbsenceEntry = oldAbsenceEntry
    newAbsenceEntry.update(type: absenceEntry.type,
                           start: absenceEntry.start,
                           end: absenceEntry.end)

    removeAbsenceEntry(oldAbsenceEntry, onlyFor: nil, &state)
    insertAbsenceEntry(newAbsenceEntry, &state)
}

private func removeAbsenceEntry(_ absenceEntry: AbsenceEntry, onlyFor day: Day?, _ state: inout TimeState) {
    state.absenceEntries.removeAll(where: { $0.id == absenceEntry.id })

    if let day = day {
        let updatedEntries = absenceEntry.removed(day: day)
        updatedEntries.forEach { entry in
            insertAbsenceEntry(entry, &state)
        }
    }
}

private extension AbsenceEntry {
    func removed(day: Day) -> [AbsenceEntry] {
        let relevantDays = self.relevantDays

        let isOnlyRelevantDay = relevantDays.count == 1 && relevantDays[0] == day
        guard !isOnlyRelevantDay else { return [] }

        guard let index = relevantDays.firstIndex(of: day) else { return [self] }

        var result: [AbsenceEntry] = []

        switch index {
        case 0:
            let newEntry = AbsenceEntry(type: self.type,
                                        start: day.addingDays(1),
                                        end: self.end)
            result.append(newEntry)

        case (relevantDays.count - 1):
            let newEntry = AbsenceEntry(type: self.type,
                                        start: self.start,
                                        end: self.end.addingDays(-1))
            result.append(newEntry)

        default:
            let newEntry1 = AbsenceEntry(type: self.type,
                                         start: self.start,
                                         end: day.addingDays(-1))
            result.append(newEntry1)

            let newEntry2 = AbsenceEntry(type: self.type,
                                         start: day.addingDays(1),
                                         end: self.end)
            result.append(newEntry2)
        }

        return result
    }
}
