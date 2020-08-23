//
//  TimerMiddleware.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import SwiftUI
import SwiftUIFlux
import WidgetKit

let globalMiddleware: Middleware<AppState> = { dispatch, getState in
    return { next in
        return { action in
            if let state = getState() as? AppState {
//                persistStateToUserDefaults(state)
            }

            return next(action)
        }
    }
}

func persistStateToUserDefaults(_ state: AppState) {
    DispatchQueue.global().async {
        let userDefaults = UserDefaults(suiteName: "group.com.d4Rk.timetracker")
        let encodedState = try? JSONEncoder().encode(state)
        userDefaults?.setValue(encodedState, forKey: "appState")

        DispatchQueue.main.async {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
