//
//  WidgetService.swift
//  timeARC
//
//  Created by d4Rk on 28.02.21.
//

import WidgetKit

class WidgetUpdateService {
    func updateWidgets(_ state: AppState) {
        DispatchQueue.global().async {
            let userDefaults = UserDefaults(suiteName: "group.com.d4rk.timearc")

            let startDate = Date().firstOfWeek
            let endDate = Date().lastOfWeek

            let relevantTimeEntries = state.timeState.timeEntries
                .timeEntries(from: startDate,
                             to: endDate)

            let workingDays = state.settingsState.workingWeekDays.workingDays(startDate: startDate,
                                                                              endDate: endDate)

            let relevantAbsenceEntries = state.timeState.absenceEntries
                .exactAbsenceEntries(for: workingDays,
                                     from: startDate,
                                     to: endDate)

            let widgetData = WidgetData(timeEntries: relevantTimeEntries,
                                        absenceEntries: relevantAbsenceEntries,
                                        workingDays: workingDays,
                                        workingDuration: state.settingsState.workingDuration,
                                        accentColor: state.settingsState.accentColor,
                                        displayMode: state.timeState.displayMode)

            let encodedWidgetData = try! JSONEncoder().encode(widgetData)
            userDefaults?.setValue(encodedWidgetData, forKey: "widgetData")

            DispatchQueue.main.async {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}
