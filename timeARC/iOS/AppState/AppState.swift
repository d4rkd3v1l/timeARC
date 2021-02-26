//
//  AppState.swift
//  timeARC
//
//  Created by d4Rk on 18.07.20.
//

import Foundation
import SwiftUIFlux

// MARK: - Store

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
    var statisticsState: StatisticsState = StatisticsState()
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
                assertionFailure("Error loading AppState data from UserDefaults.")
                completion(nil)
            }
            return
        }

        let decodedState = try? JSONDecoder().decode(AppState?.self, from: data)
        DispatchQueue.main.async {
            if decodedState == nil {
                assertionFailure("Error decoding AppState.")
            }
            completion(decodedState)
        }
    }
}
