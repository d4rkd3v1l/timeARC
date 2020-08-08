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
        var stoppedTimer = false
        for index in 0..<state.timeEntries.count {
            if state.timeEntries[index].isRunning {
                state.timeEntries[index].stop()
                stoppedTimer = true
                break
            }
        }

        if !stoppedTimer {
            state.timeEntries.append(TimeEntry())
        }

    default:
        break
    }

    return state
}
