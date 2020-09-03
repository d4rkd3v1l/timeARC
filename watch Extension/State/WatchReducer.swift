//
//  WatchReducer.swift
//  watch Extension
//
//  Created by d4Rk on 29.08.20.
//

import SwiftUIFlux

func watchReducer(state: WatchState, action: Action) -> WatchState {
    var state = state

    switch action {
    case let action as SetWatchData:
        state.timeEntries = action.timeEntries
        state.workingMinutesPerDay = action.workingMinutesPerDay
        state.accentColor = action.accentColor

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

    default:
        break
    }

    return state
}
