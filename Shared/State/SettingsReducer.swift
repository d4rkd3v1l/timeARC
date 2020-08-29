//
//  SettingsReducer.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 14.08.20.
//

import SwiftUIFlux

func settingsReducer(state: SettingsState, action: Action) -> SettingsState {
    var state = state

    switch action {
    case let action as UpdateWorkingWeekDays:
        state.workingWeekDays = action.workingWeekDays

    case let action as UpdateWorkingMinutesPerDay:
        state.workingMinutesPerDay = action.workingMinutesPerDay

    default:
        break
    }

    return state
}
