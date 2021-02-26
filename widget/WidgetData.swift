//
//  WidgetData.swift
//  widget
//
//  Created by d4Rk on 23.08.20.
//

struct WidgetData: Codable {
    let timeEntries: [Day: [TimeEntry]]
    let absenceEntries: [AbsenceEntry]
    let workingDays: [Day]
    let workingDuration: Int
    let accentColor: CodableColor
    let displayMode: TimerDisplayMode
}
