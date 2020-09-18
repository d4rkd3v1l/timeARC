//
//  timetrackerApp.swift
//  watch Extension
//
//  Created by d4Rk on 23.08.20.
//

import SwiftUI
import SwiftUIFlux

@main
struct WatchApp: App {
    let appCommunicator = AppCommunicator()

    init() {
        store.dispatch(action: InitFlux())

        store.dispatch(action: WatchStateLoadingInProgress())
        loadWatchState { watchState in
            store.dispatch(action: WatchStateLoadingSuccess(state: watchState ?? WatchState()))
        }
    }

    @SceneBuilder var body: some Scene {
        WindowGroup {
            StoreProvider(store: store) {
                ContentView()
            }
        }
        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
