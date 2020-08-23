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
    var body: some Scene {
        store.dispatch(action: InitFlux())

        loadAppState { appState in // TODO: Improve this, by showing a launch screen / spinner until done.
            store.dispatch(action: InitAppState(state: appState ?? AppState()))
        }

        return WindowGroup {
            StoreProvider(store: store) {
                ContentView()
            }
        }
    }
}
