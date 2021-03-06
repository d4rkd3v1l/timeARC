//
//  TimerActions.swift
//  timeARC
//
//  Created by d4Rk on 20.07.20.
//

import Foundation
import SwiftUIFlux

struct ToggleTimer: Action {}

struct AddTimeEntry: Action {
    let timeEntry: TimeEntry
}

struct UpdateTimeEntry: Action {
    let timeEntry: TimeEntry
}

struct DeleteTimeEntry: Action {
    let timeEntry: TimeEntry
}

struct AddAbsenceEntry: Action {
    let absenceEntry: AbsenceEntry
}

struct UpdateAbsenceEntry: Action {
    let absenceEntry: AbsenceEntry
}

struct DeleteAbsenceEntry: Action {
    let absenceEntry: AbsenceEntry
    let onlyForDay: Day?
}

struct SyncTimeEntriesFromWatch: Action {
    let timeEntries: [TimeEntry]
    let displayMode: TimerDisplayMode
}

struct RequestWatchData: Action {}

struct ChangeTimerDisplayMode: Action {
    let displayMode: TimerDisplayMode
}
