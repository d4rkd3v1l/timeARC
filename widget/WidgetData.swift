//
//  WidgetData.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 23.08.20.
//

struct WidgetData: Codable {
    let timeEntries: [Day: [TimeEntry]]
    let workingMinutesPerDay: Int
    let accentColor: CodableColor
    let displayMode: TimerDisplayMode
    
    let averageDuration: Int
    let averageBreaksDuration: Int
    let averageOvertimeDuration: Int
    let totalDuration: Int
    let totalBreaksDuration: Int
    let totalOvertimeDuration: Int
}
