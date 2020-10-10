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
    var timeEntries: [Day: [TimeEntry]] = [:]
    var absenceEntries: [AbsenceEntry] = []
    var displayMode: TimerDisplayMode = .countUp
    var didSyncWatchData: Bool = false

    private enum CodingKeys: String, CodingKey {
        case timeEntries
        case absenceEntries
        case displayMode
    }
}
//
//enum Entry: Codable {
//    case timeEntry(TimeEntry)
//    case absenceEntry(AbsenceEntry)
//
//    init(from decoder: Decoder) throws {
//        <#code#>
//    }
//
//    func encode(to encoder: Encoder) throws {
//        <#code#>
//    }
//}
//let bla: [Date: [Entry]] = [:]
