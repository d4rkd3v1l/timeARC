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
                    let duration = state.timeState.timeEntries.forDay(Day()).totalDurationInSeconds
                    let maxDuration = state.settingsState.workingMinutesPerDay * 60
                    let endOfWorkingDayDate = Date().addingTimeInterval(5)//TimeInterval(maxDuration - duration))
                    scheduleEndOfWorkingDayNotification(for: endOfWorkingDayDate)
                } else {
                    removeEndOfWorkingDayNotification()
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
                                  workingMinutesPerDay: state.settingsState.workingMinutesPerDay,
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

        let relevantTimeEntries = state.timeState.timeEntries.forDay(Day())
        let widgetData = WidgetData(timeEntries: relevantTimeEntries,
                                    workingMinutesPerDay: state.settingsState.workingMinutesPerDay,
                                    accentColor: state.settingsState.accentColor,
                                    displayMode: state.timeState.displayMode)

        let encodedWidgetData = try! JSONEncoder().encode(widgetData)
        userDefaults?.setValue(encodedWidgetData, forKey: "widgetData")

        DispatchQueue.main.async {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

private func scheduleEndOfWorkingDayNotification(for date: Date) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
        if success {
            removeEndOfWorkingDayNotification()

            let content = UNMutableNotificationContent()
            content.title = "Congratulations"
            content.subtitle = "You're done for today! 🥳"
//            content.subtitle = "You're done for this week! 🙌"
            content.sound = UNNotificationSound.default

            let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                                        from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)

            let request = UNNotificationRequest(identifier: "endOfWorkingDayNotification",
                                                content: content,
                                                trigger: trigger)

            UNUserNotificationCenter.current().add(request)
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
}

private func removeEndOfWorkingDayNotification() {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["endOfWorkingDayNotification"])
}
