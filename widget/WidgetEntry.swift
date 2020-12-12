//
//  WidgetEntry.swift
//  timetracker
//
//  Created by d4Rk on 01.11.20.
//

import SwiftUI
import WidgetKit

struct WidgetEntry: TimelineEntry {
    let date: Date

    let todayDuration: Int
    let todayMaxDuration: Int
    let isTodayWorkingDay: Bool
    let weekDuration: Int
    let weekMaxDuration: Int
    let weekAverageDuration: Int
    let weekAverageBreaksDuration: Int
    let weekTotalBreaksDuration: Int
    let weekAverageOvertimeDuration: Int
    let weekTotalOvertimeDuration: Int
    let isRunning: Bool
    let accentColor: Color
    let displayMode: TimerDisplayMode
}
