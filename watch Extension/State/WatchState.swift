//
//  WatchState.swift
//  watch Extension
//
//  Created by d4Rk on 29.08.20.
//

import Foundation
import SwiftUIFlux

// MARK: - Store

let store = Store<WatchState>(reducer: watchReducer,
                              middleware: [watchMiddleware],
                              state: WatchState())
struct InitFlux: Action {}
struct InitAppState: Action {
    let state: WatchState
}

// MARK: - AppState

struct WatchState: FluxState, Codable {
    var isWatchStateLoading: Bool = false
    var timeEntries: [TimeEntry] = []
    var displayMode: TimerDisplayMode = .countUp
    var workingMinutesPerDay: Int = 480
    var accentColor: CodableColor = .green
}

// MARK: - Persistence

func saveWatchState(_ state: WatchState) {
    DispatchQueue.global().async {
        let userDefaults = UserDefaults.standard
        let encodedState = try? JSONEncoder().encode(state)
        userDefaults.setValue(encodedState, forKey: "watchState")
    }
}

func loadWatchState(_ completion: @escaping (WatchState?) -> Void) {
    DispatchQueue.global().async {
        let userDefaults = UserDefaults.standard

        guard let data = userDefaults.data(forKey: "watchState") else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }

        let decodedState = try? JSONDecoder().decode(WatchState?.self, from: data)
        DispatchQueue.main.async {
            completion(decodedState)
        }
    }
}
