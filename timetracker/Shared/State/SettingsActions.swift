//
//  SettingsActions.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 14.08.20.
//

import SwiftUI
import SwiftUIFlux

struct UpdateWorkingWeekDays: Action {
    let workingWeekDays: [WeekDay]
}

struct UpdateWorkingMinutesPerDay: Action {
    let workingMinutesPerDay: Int
}

struct UpdateAccentColor: Action {
    let color: Color
}
