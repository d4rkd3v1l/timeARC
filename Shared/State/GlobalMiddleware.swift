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
                saveAppState(state) // TODO: optimize, don't do this for any action?

                if action is SyncTimeEntriesFromWatch {
                    updateWidgetData(state)
                } else {
                    sendDataToWatch(state)
                }
            }
        }
    }
}

private func sendDataToWatch(_ state: AppState) { // TODO: Optimize, by only sending new data, if actual relevant changes did happen
    DispatchQueue.global().async {
        let relevantTimeEntries = state.timeState.timeEntries.filter { $0.isRelevant(for: Date()) }
        let data = AppToWatchData(timeEntries: relevantTimeEntries,
                                  workingMinutesPerDay: state.settingsState.workingMinutesPerDay,
                                  accentColor: state.settingsState.accentColor)

        if let encodedData = try? JSONEncoder().encode(data) {
            DispatchQueue.main.async {
                WCSession.default.sendMessageData(encodedData, replyHandler: nil)
            }
        }
    }
}

func updateWidgetData(_ state: AppState) {
    DispatchQueue.global().async {
        let userDefaults = UserDefaults(suiteName: "group.com.d4Rk.timetracker")

        let relevantTimeEntries = state.timeState.timeEntries.filter { $0.isRelevant(for: Date()) }
        let widgetData = WidgetData(timeEntries: relevantTimeEntries,
                                    workingMinutesPerDay: state.settingsState.workingMinutesPerDay,
                                    accentColor: state.settingsState.accentColor)

        let encodedWidgetData = try? JSONEncoder().encode(widgetData)
        userDefaults?.setValue(encodedWidgetData, forKey: "widgetData")

        DispatchQueue.main.async {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
