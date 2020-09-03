//
//  WatchState.swift
//  watch Extension
//
//  Created by d4Rk on 29.08.20.
//

import SwiftUIFlux

// MARK: - Store

let store = Store<WatchState>(reducer: watchReducer,
                              middleware: [watchMiddleware],
                              state: WatchState())

// MARK: - AppState

struct WatchState: FluxState, Codable {
    var timeEntries: [TimeEntry] = []
    var workingMinutesPerDay: Int = 480
    var accentColor: CodableColor = .green
}
