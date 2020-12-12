//
//  Provider.swift
//  timetracker
//
//  Created by d4Rk on 01.11.20.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        self.providePlaceholder()
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        let entry = self.providePlaceholder()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> ()) {
        guard let userDefaults = UserDefaults(suiteName: "group.com.d4Rk.timetracker"),
              let decodedWidgetData = userDefaults.data(forKey: "widgetData"),
              let widgetData = try? JSONDecoder().decode(WidgetData.self, from: decodedWidgetData) else { return }

        let isRunning = widgetData.timeEntries.isTimerRunning

        if isRunning {
            var entries: [WidgetEntry] = []
            for minute in 0..<2 { // 24h should be sufficient?! -> TODO: Check if Timeline.policy acutally works, then this time could be reduced. Trigger first update now, and every following one to the full minute? This would increase precision between Widget and App, and performance.
                let advancedSeconds = minute * 60
                let entry = self.provideEntry(for: advancedSeconds, widgetData: widgetData)
                entries.append(entry)
            }

            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        } else {
            let entry = self.provideEntry(for: 0, widgetData: widgetData)
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
        }
    }

    private func provideEntry(for advancedSeconds: Int, widgetData: WidgetData) -> WidgetEntry {
        var timeEntries = widgetData.timeEntries
        var timeEntriesToday = timeEntries[Day()]
        if let runningTimeEntryIndex = timeEntriesToday?.firstIndex(where: { $0.isRunning }) {
            timeEntriesToday?[runningTimeEntryIndex].end?.addTimeInterval(Double(advancedSeconds))
            timeEntries[Day()] = timeEntriesToday
        }

        let todayDuration = timeEntries.forDay(Day()).totalDurationInSeconds
        let todayMaxDuration = widgetData.workingDuration
        let isTodayWorkingDay = widgetData.workingDays.contains(Date().day)
        let weekDuration = timeEntries.totalDuration(workingDuration: widgetData.workingDuration,
                                                     absenceEntries: widgetData.absenceEntries)
        let weekMaxDuration = widgetData.workingDuration * widgetData.workingDays.count
        let weekAverageDuration = timeEntries.averageDuration(workingDays: widgetData.workingDays)
        let weekAverageBreaksDuration = timeEntries.averageBreaksDuration()
        let weekTotalBreaksDuration = timeEntries.totalBreaksDuration()
        let weekAverageOvertimeDuration = timeEntries.averageOvertimeDuration(workingDays: widgetData.workingDays,
                                                                              workingDuration: widgetData.workingDuration)
        let weekTotalOvertimeDuration = timeEntries.totalOvertimeDuration(workingDays: widgetData.workingDays,
                                                                          workingDuration: widgetData.workingDuration,
                                                                          absenceEntries: widgetData.absenceEntries)
        let accentColor = widgetData.accentColor.color
        let displayMode = widgetData.displayMode

        return WidgetEntry(date: Date().addingTimeInterval(Double(advancedSeconds)),
                           todayDuration: todayDuration,
                           todayMaxDuration: todayMaxDuration,
                           isTodayWorkingDay: isTodayWorkingDay,
                           weekDuration: weekDuration,
                           weekMaxDuration: weekMaxDuration,
                           weekAverageDuration: weekAverageDuration,
                           weekAverageBreaksDuration: weekAverageBreaksDuration,
                           weekTotalBreaksDuration: weekTotalBreaksDuration,
                           weekAverageOvertimeDuration: weekAverageOvertimeDuration,
                           weekTotalOvertimeDuration: weekTotalOvertimeDuration,
                           isRunning: timeEntries.isTimerRunning,
                           accentColor: accentColor,
                           displayMode: displayMode)
    }

    func providePlaceholder(isTodayWorkingDay: Bool = true) -> WidgetEntry {
        return WidgetEntry(date: Date(),
                           todayDuration: 2520,
                           todayMaxDuration: 28800,
                           isTodayWorkingDay: isTodayWorkingDay,
                           weekDuration: 2520,
                           weekMaxDuration: 144000,
                           weekAverageDuration: 1,
                           weekAverageBreaksDuration: 2,
                           weekTotalBreaksDuration: 3,
                           weekAverageOvertimeDuration: 4,
                           weekTotalOvertimeDuration: 5,
                           isRunning: true,
                           accentColor: .green,
                           displayMode: .countUp)
    }
}
