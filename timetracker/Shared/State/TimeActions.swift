//
//  TimerActions.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import Foundation
import SwiftUIFlux

struct ToggleTimer: Action {}

struct AddTimeEntry: Action {
    let start: Date
    let end: Date
}

struct UpdateTimeEntry: Action {
    let timeEntry: TimeEntry
}

struct DeleteTimeEntry: Action {
    let timeEntry: TimeEntry
}

struct SyncTimeEntriesFromWatch: Action {
    let timeEntries: [TimeEntry]
}

struct RequestWatchData: Action {}

struct ChangeTimerDisplayMode: Action {
    let displayMode: TimerDisplayMode
}
