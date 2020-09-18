//
//  AppState.swift
//  timetracker
//
//  Created by d4Rk on 18.07.20.
//

import Foundation
import SwiftUIFlux

// MARK: - Store

let store = Store<AppState>(reducer: appStateReducer,
                            middleware: [globalMiddleware],
                            state: AppState())
struct InitFlux: Action {}
struct AppStateLoadingInProgress: Action {}
struct AppStateLoadingSuccess: Action {
    let state: AppState
}

// MARK: - AppState

struct AppState: FluxState, Codable {
    var isAppStateLoading: Bool = true
    var timeState: TimeState = TimeState()
    var settingsState: SettingsState = SettingsState()
}

private func appStateReducer(state: AppState, action: Action) -> AppState {
    var newState: AppState
    switch action {

    case _ as AppStateLoadingInProgress:
        newState = AppState()
        newState.isAppStateLoading = true

    case let action as AppStateLoadingSuccess:
        newState = action.state
        newState.isAppStateLoading = false

    default:
        newState = state
    }

    newState.timeState = timeReducer(state: newState.timeState, action: action)
    newState.settingsState = settingsReducer(state: newState.settingsState, action: action)
    return newState
}

// MARK: - Persistence

func saveAppState(_ state: AppState) {
    DispatchQueue.global().async {
        let userDefaults = UserDefaults.standard
        let encodedState = try? JSONEncoder().encode(state)
        userDefaults.setValue(encodedState, forKey: "appState")
    }
}

func loadAppState(_ completion: @escaping (AppState?) -> Void) {
    DispatchQueue.global().async {
        let userDefaults = UserDefaults.standard

        guard let data = userDefaults.data(forKey: "appState") else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }

        let decodedState = try? JSONDecoder().decode(AppState?.self, from: data)
        DispatchQueue.main.async {
            completion(decodedState)
        }
    }
}

// MARK: - Models

enum AbsenceType { // Too strict?
    case bankHoliday
    case holiday
    case sick // child sick?
}

struct AbsenceEntry {
    let type: AbsenceType
    let date: Date
}
