//
//  timetrackerApp.swift
//  Shared
//
//  Created by d4Rk on 18.07.20.
//

import SwiftUI
import SwiftUIFlux

@main
struct app: App {
    let watchCommunicator = WatchCommunicator()

    init() {
        store.dispatch(action: InitFlux())

        store.dispatch(action: AppStateLoadingInProgress())
        loadAppState { appState in
            store.dispatch(action: AppStateLoadingSuccess(state: appState ?? AppState()))
        }
    }

    var body: some Scene {
        WindowGroup {
            StoreProvider(store: store) {
                ContentView()
            }
        }
    }
}
