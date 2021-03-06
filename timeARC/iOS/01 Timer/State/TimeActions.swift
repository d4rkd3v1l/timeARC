//
//  TimerActions.swift
//  timeARC
//
//  Created by d4Rk on 20.07.20.
//

import Foundation
import SwiftUIFlux

enum Source {
    case local
    case remote
}

protocol ActionWithSource: Action {
    var source: Source { get }
}

struct ToggleTimer: Action {}

struct AddTimeEntry: ActionWithSource {
    let timeEntry: TimeEntry
    let source: Source
}

struct UpdateTimeEntry: ActionWithSource {
    let timeEntry: TimeEntry
    let source: Source
}

struct DeleteTimeEntry: ActionWithSource {
    let timeEntry: TimeEntry
    let source: Source
}

struct DeleteTimeEntryById: ActionWithSource {
    let id: UUID
    let source: Source
}

struct AddAbsenceEntry: ActionWithSource {
    let absenceEntry: AbsenceEntry
    let source: Source
}

struct UpdateAbsenceEntry: ActionWithSource {
    let absenceEntry: AbsenceEntry
    let source: Source
}

struct DeleteAbsenceEntry: ActionWithSource {
    let absenceEntry: AbsenceEntry
    let onlyForDay: Day?
    let source: Source
}

struct DeleteAbsenceEntryById: ActionWithSource {
    let id: UUID
    let source: Source
}

struct SyncTimeEntriesFromWatch: Action {
    let timeEntries: [TimeEntry]
    let displayMode: TimerDisplayMode
}

struct RequestWatchData: Action {}

struct ChangeTimerDisplayMode: Action {
    let displayMode: TimerDisplayMode
}
