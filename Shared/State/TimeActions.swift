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
    let id: UUID
    let start: Date
    let end: Date?
}

struct DeleteTimeEntry: Action {
    let id: UUID
}

struct SyncTimeEntriesFromWatch: Action {
    let timeEntries: [TimeEntry]
}

struct RequestWatchData: Action {}

struct ChangeTimerDisplayMode: Action {
    let displayMode: TimerDisplayMode
}
