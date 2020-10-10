//
//  TimerReducer.swift
//  timetracker
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
            state.updateTimeEntryValidated(runningTimeEntry)
            didStopTimer = true
        }

        if !didStopTimer {
            state.insertTimeEntryValidated(TimeEntry())
        }

    case let action as AddTimeEntry:
        state.insertTimeEntryValidated(action.timeEntry)

    case let action as UpdateTimeEntry:
        state.updateTimeEntryValidated(action.timeEntry)

    case let action as DeleteTimeEntry:
        state.removeTimeEntry(action.timeEntry)

    case let action as AddAbsenceEntry:
        state.insertAbsenceEntry(action.absenceEntry)

    case let action as UpdateAbsenceEntry:
        state.updateAbsenceEntry(action.absenceEntry)

    case let action as DeleteAbsenceEntry:
        state.removeAbsenceEntry(action.absenceEntry, onlyFor: action.onlyForDay)

    case let action as SyncTimeEntriesFromWatch:
        action.timeEntries.forEach { timeEntry in
            if state.timeEntries.find(timeEntry) != nil {
                state.updateTimeEntryValidated(timeEntry)
            } else {
                state.insertTimeEntryValidated(timeEntry)
            }
        }
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
