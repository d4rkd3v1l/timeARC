//
//  WidgetData.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 23.08.20.
//

struct WidgetData: Codable {
    let timeEntries: [TimeEntry]
    let workingHoursPerDay: Int
}
