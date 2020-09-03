//
//  SettingsState.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 14.08.20.
//

import SwiftUI
import SwiftUIFlux

struct SettingsState: FluxState, Codable {
    var workingWeekDays: [WeekDay] = [.monday,
                                      .tuesday,
                                      .wednesday,
                                      .thursday,
                                      .friday]
    var workingMinutesPerDay: Int = 480
    var accentColor: CodableColor = .green
}
