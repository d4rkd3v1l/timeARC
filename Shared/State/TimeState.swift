//
//  TimerState.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import SwiftUIFlux

struct TimeState: FluxState, Codable {
    var timeEntries: [TimeEntry] = []
    var displayMode: TimerDisplayMode = .countUp
    var didSyncWatchData: Bool = false

    private enum CodingKeys: String, CodingKey {
        case timeEntries
        case displayMode
    }
}
