//
//  TimerState.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import Foundation
import SwiftUIFlux

struct TimeState: FluxState, Codable {
    /// `Date` is start of day, `TimeEntry`s are sorted by start ascending
    var timeEntries: [Date: [TimeEntry]] = [:]
    var displayMode: TimerDisplayMode = .countUp
    var didSyncWatchData: Bool = false

    private enum CodingKeys: String, CodingKey {
        case timeEntries
        case displayMode
    }
}
