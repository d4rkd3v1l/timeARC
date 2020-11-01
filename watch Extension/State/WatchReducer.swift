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
    case _ as WatchStateLoadingInProgress:
        state.isWatchStateLoading = true

    case let action as WatchStateLoadingSuccess:
        state = action.state
        state.isWatchStateLoading = false

    case let action as SetWatchData:
        state.timeEntries = action.timeEntries
        state.displayMode = action.displayMode
        state.workingDuration = action.workingDuration
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

    case let action as ChangeTimerDisplayMode:
        state.displayMode = action.displayMode

    default:
        break
    }

    return state
}
