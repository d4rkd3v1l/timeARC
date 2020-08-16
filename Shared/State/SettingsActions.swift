//
//  SettingsActions.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 14.08.20.
//

import SwiftUIFlux

struct UpdateWorkingWeekDays: Action {
    let workingWeekDays: [WeekDay]
}

struct UpdateWorkingHoursPerDay: Action {
    let workingHoursPerDay: Int
}
