//
//  StatisticsState.swift
//  timetracker
//
//  Created by d4Rk on 20.09.20.
//

import SwiftUI
import SwiftUIFlux

struct StatisticsState: FluxState, Codable {
    var selectedTimeFrame: TimeFrame = .week
    var selectedStartDate: Date = Date()
    var selectedEndDate: Date = Date()

    var selectedDateText: String = ""
    var errorMessage: String?

    var targetDuration: Int = 0                     // working hours
    var averageDuration: Int = 0                    // duration of all time entries / working days
    var averageWorkingHoursStartDate: Date = Date() // average of start of first time entry on each day
    var averageWorkingHoursEndDate: Date = Date()   // average of end of last time entry on each day
    var averageBreaksDuration: Int = 0              // breaks of all days / working days
    var averageOvertimeDuration: Int = 0            // "averageDuration" - working hours

    var totalDays: Int = 0                          // working days
    var totalDaysWorked: Int = 0                    // days with time entries
    var totalDuration: Int = 0                      // duration of all time entries
    var totalBreaksDuration: Int = 0                // breaks of all days
    var totalOvertimeDuration: Int = 0              // "totalDuration" - working hours * working days

    var totalAbsenceDuration: Float = 0             // off-factor of absence with highest off-factor * working hours per day of all days
    var totalDaysAbsentByType: [AbsenceType: Float] = [:]
}
