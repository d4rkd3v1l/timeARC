//
//  WatchActions.swift
//  watch Extension
//
//  Created by d4Rk on 29.08.20.
//

import SwiftUIFlux

struct SetWatchData: Action {
    let timeEntries: [TimeEntry]
    let workingMinutesPerDay: Int
    let accentColor: CodableColor
}

struct ToggleTimer: Action {}
