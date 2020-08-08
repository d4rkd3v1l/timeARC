//
//  timetrackerApp.swift
//  Shared
//
//  Created by d4Rk on 18.07.20.
//

import SwiftUI
import SwiftUIFlux

@main
struct timetrackerApp: App {
    var body: some Scene {
        store.dispatch(action: InitFlux())
        return WindowGroup {
            StoreProvider(store: store) {
                ContentView()
            }
        }
    }
}
