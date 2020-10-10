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
            state.timeEntries.updateValidated(runningTimeEntry)
            didStopTimer = true
        }

        if !didStopTimer {
            state.timeEntries.insertValidated(TimeEntry())
        }

    case let action as AddTimeEntry:
        state.timeEntries.insertValidated(action.timeEntry)

    case let action as UpdateTimeEntry:
        state.timeEntries.updateValidated(action.timeEntry)

    case let action as DeleteTimeEntry:
        state.timeEntries.remove(action.timeEntry)

    case let action as AddAbsenceEntry:
        state.absenceEntries.append(action.absenceEntry)

        

    case let action as UpdateAbsenceEntry:
        guard let oldAbsenceEntry = state.absenceEntries.first(where: { $0 == action.absenceEntry }) else { break }

        var newAbsenceEntry = oldAbsenceEntry
        newAbsenceEntry.update(type: action.absenceEntry.type,
                               start: action.absenceEntry.start,
                               end: action.absenceEntry.end)

        state.absenceEntries.removeAll(where: { $0 == action.absenceEntry })
        state.absenceEntries.append(newAbsenceEntry)

    case let action as DeleteAbsenceEntry:
        state.absenceEntries.removeAll(where: { $0 == action.absenceEntry })

    case let action as SyncTimeEntriesFromWatch:
        action.timeEntries.forEach { timeEntry in
            if state.timeEntries.find(timeEntry) != nil {
                state.timeEntries.updateValidated(timeEntry)
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
