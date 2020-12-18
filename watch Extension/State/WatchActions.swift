//
//  WatchActions.swift
//  watch Extension
//
//  Created by d4Rk on 29.08.20.
//

import SwiftUIFlux

struct WatchStateLoadingInProgress: Action {}

struct WatchStateLoadingSuccess: Action {
    let state: WatchState
}

struct SetWatchData: Action {
    let timeEntries: [TimeEntry]
    let displayMode: TimerDisplayMode
    let isTodayWorkingDay: Bool
    let workingDuration: Int
    let accentColor: CodableColor
}

struct ToggleTimer: Action {}

struct SendDataToApp: Action {}

struct ChangeTimerDisplayMode: Action {
    let displayMode: TimerDisplayMode
}
