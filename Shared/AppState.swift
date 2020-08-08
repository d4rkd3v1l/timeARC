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
}

private func appStateReducer(state: AppState, action: Action) -> AppState {
    var state = state
    state.timeState = timeReducer(state: state.timeState, action: action)
    return state
}

// MARK: - SettingsState

enum WeekDay: CaseIterable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

struct SettingsState: FluxState {
    var workingWeekDays: [WeekDay] = [.monday,
                                      .tuesday,
                                      .wednesday,
                                      .thursday,
                                      .friday]
    var workingHoursPerDay: Int = 8 // Alternative: weekly?

    // TODO list (prioritized)
    // iCloud sync
    // auto break
    // projects?
    // simultaneous timers?
    // start of new day (default 00:00)
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
