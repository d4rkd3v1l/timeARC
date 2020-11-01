//
//  TimerMiddleware.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import SwiftUI
import SwiftUIFlux
import WatchConnectivity
import WidgetKit

private let endOfWoringDayNotificationIdentifier = "endOfWoringDayNotificationIdentifier"
private let endOfWoringWeekNotificationIdentifier = "endOfWoringWeekNotificationIdentifier"

let globalMiddleware: Middleware<AppState> = { dispatch, getState in
    return { next in
        return { action in
            next(action)

            if let state = getState() as? AppState {
                saveAppState(state) // TODO: Optimize, don't do this for any action?
                updateWidgetData(state)

                if state.timeState.didSyncWatchData {
                    sendDataToWatch(state)
                }

                if state.timeState.timeEntries.isTimerRunning {
                    scheduleEndOfWorkingDayNotification(state: state)
                    scheduleEndOfWorkingWeekNotification(state: state)
                } else {
                    removeNotifications(identifiers: [endOfWoringDayNotificationIdentifier,
                                                      endOfWoringWeekNotificationIdentifier])
                }
            }

            switch action {
            case _ as RequestWatchData:
                requestWatchData()

            default:
                break
            }
        }
    }
}

private func sendDataToWatch(_ state: AppState) { // TODO: Optimize, by only sending new data, if actual relevant changes did happen
    DispatchQueue.global().async {
        let relevantTimeEntries = state.timeState.timeEntries.forDay(Day())

        let data = AppToWatchData(timeEntries: relevantTimeEntries,
                                  displayMode: state.timeState.displayMode,
                                  workingDuration: state.settingsState.workingDuration,
                                  accentColor: state.settingsState.accentColor)

        let encodedData = try! JSONEncoder().encode(data)
            DispatchQueue.main.async {
                WCSession.default.sendMessageData(encodedData, replyHandler: nil)
            }

    }
}

private func requestWatchData() {
    let encodedData = try! JSONEncoder().encode("requestWatchData")
        WCSession.default.sendMessageData(encodedData, replyHandler: nil)

}

func updateWidgetData(_ state: AppState) {
    DispatchQueue.global().async {
        let userDefaults = UserDefaults(suiteName: "group.com.d4Rk.timetracker")

        let startDate = Date().firstOfWeek
        let endDate = Date().lastOfWeek

        let relevantTimeEntries = state.timeState.timeEntries
            .timeEntries(from: startDate,
                         to: endDate)

        let relevantAbsenceEntries = state.timeState.absenceEntries
            .exactAbsenceEntries(from: startDate,
                                 to: endDate)

        let widgetData = WidgetData(timeEntries: relevantTimeEntries,
                                    absenceEntries: relevantAbsenceEntries,
                                    workingDays: state.settingsState.workingWeekDays.workingDays(startDate: startDate,
                                                                                                 endDate: endDate),
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

private func scheduleEndOfWorkingDayNotification(state: AppState) {
    let duration = state.timeState.timeEntries.forDay(Day()).totalDurationInSeconds
    let maxDuration = state.settingsState.workingDuration
    let endOfWorkingDayDate = Date().addingTimeInterval(TimeInterval(maxDuration - duration))

    removeNotifications(identifiers: [endOfWoringDayNotificationIdentifier])
    scheduleNotification(with: "endOfWoringDayNotificationTitle",
                         subtitle: "endOfWoringDayNotificationSubtitle",
                         identifier: endOfWoringDayNotificationIdentifier,
                         for: endOfWorkingDayDate)
}

private func scheduleEndOfWorkingWeekNotification(state: AppState) {
    let duration = state.timeState.timeEntries
        .filter { (Date().firstOfWeek...Date().lastOfWeek).contains($0.key.date) }
        .flatMap { $0.value }
        .totalDurationInSeconds

    let maxDuration = state.settingsState.workingDuration * state.settingsState.workingWeekDays.count
    let endOfWorkingWeekDate = Date().addingTimeInterval(TimeInterval(maxDuration - duration))

    removeNotifications(identifiers: [endOfWoringWeekNotificationIdentifier])
    scheduleNotification(with: "endOfWoringWeekNotificationTitle",
                         subtitle: "endOfWoringWeekNotificationSubtitle",
                         identifier: endOfWoringWeekNotificationIdentifier,
                         for: endOfWorkingWeekDate)
}

private func scheduleNotification(with title: String, subtitle: String, identifier: String, for date: Date) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
        if success {
            let content = UNMutableNotificationContent()
            content.title = title
            content.subtitle = subtitle
            content.sound = UNNotificationSound.default

            let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                                        from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)

            let request = UNNotificationRequest(identifier: identifier,
                                                content: content,
                                                trigger: trigger)

            UNUserNotificationCenter.current().add(request)
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
}

private func removeNotifications(identifiers: [String]) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
}
