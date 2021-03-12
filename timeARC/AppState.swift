//
//  AppState.swift
//  timeARC
//
//  Created by d4Rk on 18.07.20.
//

import Foundation
import SwiftUIFlux

// MARK: - Store

struct InitAppState: Action {
    let state: AppState
}

// MARK: - AppState

struct AppState: FluxState, Codable {
    var isAppStateLoading: Bool = true
    var timeState: TimeState = TimeState()
    var settingsState: SettingsState = SettingsState()
    var statisticsState: StatisticsState = StatisticsState()
}
