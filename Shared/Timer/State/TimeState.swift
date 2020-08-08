//
//  TimerState.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import Foundation
import SwiftUIFlux

struct TimeState: FluxState {
    var timeEntries: [TimeEntry] = [TimeEntry(start: Date(timeIntervalSinceNow: -20000), end: nil)]
}
