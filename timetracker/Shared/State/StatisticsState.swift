//
//  StatisticsState.swift
//  timetracker
//
//  Created by d4Rk on 20.09.20.
//

import SwiftUI
import SwiftUIFlux

struct StatisticsState: FluxState, Codable {
    var selectedTimeFrame: TimeFrame = .allTime
    var selectedStartDate: Date = Date()
    var selectedEndDate: Date = Date()
    var selectedDateText: String = ""

    var errorMessage: String?

    var targetDuration: Int = 0
    var averageDuration: Int = 0
    var averageWorkingHoursStartDate: Date = Date()
    var averageWorkingHoursEndDate: Date = Date()
    var averageBreaksDuration: Int = 0
    var averageOvertimeDuration: Int = 0

    var totalDays: Int = 0
    var totalDaysWorked: Int = 0
    var totalDuration: Int = 0
    var totalBreaksDuration: Int = 0
    var totalOvertimeDuration: Int = 0
    // TODO: AbsenceTypes

    // TODO: Avoid direct access to other states
    var timeEntries: [Day: [TimeEntry]] { store.state.timeState.timeEntries }
    var workingMinutesPerDay: Int { store.state.settingsState.workingMinutesPerDay }
    var workingWeekDays: [WeekDay] { store.state.settingsState.workingWeekDays }
}
