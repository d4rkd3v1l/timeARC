//
//  TimerReducer.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import SwiftUIFlux

func timeReducer(state: TimeState, action: Action) -> TimeState {
    var state = state

    switch action {
    case _ as ToggleTimer:
        var didStopTimer = false
        for index in 0..<state.timeEntries.count {
            if state.timeEntries[index].isRunning {
                state.timeEntries[index].stop()
                didStopTimer = true
                break
            }
        }

        if !didStopTimer {
            state.timeEntries.append(TimeEntry())
        }

    case let action as AddTimeEntry:
        let entry = TimeEntry(start: action.start, end: action.end)
        state.timeEntries.append(entry)

    case let action as UpdateTimeEntry:
        guard let index = state.timeEntries.firstIndex(where: { $0.id == action.id }) else { break }
        state.timeEntries[index].start = action.start
        state.timeEntries[index].end = action.end

    case let action as DeleteTimeEntry:
        guard let index = state.timeEntries.firstIndex(where: { $0.id == action.id }) else { break }
        state.timeEntries.remove(at: index)

    case let action as SyncTimeEntriesFromWatch: // TODO: Review this^^
        action.timeEntries.forEach { timeEntry in
            if state.timeEntries.contains(timeEntry) {
                state.timeEntries.removeAll(where: { $0 == timeEntry })
            }

            state.timeEntries.append(timeEntry)
        }

    default:
        break
    }

    return state
}
