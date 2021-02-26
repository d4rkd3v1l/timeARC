//
//  SettingsReducer.swift
//  timeARC
//
//  Created by d4Rk on 14.08.20.
//

import SwiftUIFlux

func settingsReducer(state: SettingsState, action: Action) -> SettingsState {
    var state = state

    switch action {
    case let action as UpdateWorkingWeekDays:
        state.workingWeekDays = action.workingWeekDays

    case let action as UpdateWorkingDuration:
        state.workingDuration = action.workingDuration

    case let action as UpdateAccentColor:
        state.accentColor = action.color

    default:
        break
    }

    return state
}
