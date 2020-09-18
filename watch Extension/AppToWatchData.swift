//
//  WatchData.swift
//  watch Extension
//
//  Created by d4Rk on 29.08.20.
//

struct AppToWatchData: Codable {
    let timeEntries: [TimeEntry]
    let displayMode: TimerDisplayMode
    let workingMinutesPerDay: Int
    let accentColor: CodableColor
}

struct WatchToAppData: Codable {
    let timeEntries: [TimeEntry]
    let displayMode: TimerDisplayMode
}
