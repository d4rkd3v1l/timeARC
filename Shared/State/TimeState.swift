//
//  TimerState.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import SwiftUIFlux

struct TimeState: FluxState, Codable {
    var timeEntries: [TimeEntry] = []
}
