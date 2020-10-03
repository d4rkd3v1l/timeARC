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
        let timeEntriesForDay = state.timeEntries.forDay(Date())
        if var runningTimeEntry = timeEntriesForDay.first(where: { $0.isRunning }) {
            runningTimeEntry.stop()
            state.timeEntries.updateValidated(runningTimeEntry)
            didStopTimer = true
        }

        if !didStopTimer {
            state.timeEntries.insertValidated(TimeEntry())
        }

    case let action as AddTimeEntry:
        let entry = TimeEntry(start: action.start, end: action.end)
        state.timeEntries.insertValidated(entry)

    case let action as UpdateTimeEntry:
        state.timeEntries.updateValidated(action.timeEntry)

    case let action as DeleteTimeEntry:
        state.timeEntries.remove(action.timeEntry)

    case let action as SyncTimeEntriesFromWatch:
        action.timeEntries.forEach { timeEntry in
            if let localEntry = state.timeEntries.find(timeEntry) {
                state.timeEntries.remove(localEntry)
                state.timeEntries.insertValidated(localEntry.lastModified > timeEntry.lastModified ? localEntry : timeEntry)
            } else {
                state.timeEntries.insertValidated(timeEntry)
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
