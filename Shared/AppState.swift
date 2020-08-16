//
//  AppState.swift
//  timetracker
//
//  Created by d4Rk on 18.07.20.
//

import Foundation
import SwiftUIFlux

// MARK: - Store

let store = Store<AppState>(reducer: appStateReducer,
                            middleware: [timeMiddleware],
                            state: AppState())
struct InitFlux: Action {}

// MARK: - AppState

struct AppState: FluxState {
    var timeState: TimeState = TimeState()
    var settingsState: SettingsState = SettingsState()
}

private func appStateReducer(state: AppState, action: Action) -> AppState {
    var state = state
    state.timeState = timeReducer(state: state.timeState, action: action)
    state.settingsState = settingsReducer(state: state.settingsState, action: action)
    return state
}

// MARK: - Models

enum AbsenceType { // Too strict?
    case bankHoliday
    case holiday
    case sick // child sick?
}

struct AbsenceEntry {
    let type: AbsenceType
    let date: Date
}
