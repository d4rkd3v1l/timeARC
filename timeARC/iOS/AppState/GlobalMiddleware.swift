//
//  TimerMiddleware.swift
//  timeARC
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

            case let action as UpdateAccentColor:
                updateAppIcon(with: action.color.color(for: action.colorScheme),
                              for: action.colorScheme)

            default:
                break
            }
        }
    }
}

// MARK: - Watch Sync

private func sendDataToWatch(_ state: AppState) { // TODO: Optimize, by only sending new data, if actual relevant changes did happen
    DispatchQueue.global().async {
        let relevantTimeEntries = state.timeState.timeEntries.forDay(Day())
        let workingDays = state.settingsState.workingWeekDays.workingDays(startDate: Date(), endDate: Date())
        let isTodayWorkingDay = workingDays.contains(Day()) || !relevantTimeEntries.isEmpty

        let data = AppToWatchData(timeEntries: relevantTimeEntries,
                                  displayMode: state.timeState.displayMode,
                                  isTodayWorkingDay: isTodayWorkingDay,
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

// MARK: - Widget Sync

// TODO: Don't use the whole state here!
func updateWidgetData(_ state: AppState) {
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

// MARK: - Notifications

private func scheduleEndOfWorkingDayNotification(state: AppState) {
    let duration = state.timeState.timeEntries.forDay(Day()).totalDurationInSeconds
    let maxDuration = state.settingsState.workingDuration
    let endOfWorkingDayDate = Date().addingTimeInterval(TimeInterval(maxDuration - duration))

    removeNotifications(identifiers: [endOfWoringDayNotificationIdentifier])
    scheduleNotification(with: NSLocalizedString("endOfWoringDayNotificationTitle", comment: ""),
                         body: NSLocalizedString("endOfWoringDayNotificationBody", comment: ""),
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
    scheduleNotification(with: NSLocalizedString("endOfWoringWeekNotificationTitle", comment: ""),
                         body: NSLocalizedString("endOfWoringWeekNotificationBody", comment: ""),
                         identifier: endOfWoringWeekNotificationIdentifier,
                         for: endOfWorkingWeekDate)
}

private func scheduleNotification(with title: String, body: String, identifier: String, for date: Date) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
        if success {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
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

// MARK: - App Icon

private func updateAppIcon(with color: Color, for colorScheme: ColorScheme) {
    let iconName = "icon_\(colorScheme)_\(color)"
    UIApplication.shared.setAlternateIconName(iconName)
}
