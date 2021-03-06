//
//  App.swift
//  timeARC
//
//  Created by d4Rk on 18.07.20.
//

import SwiftUI
import SwiftUIFlux
import Resolver
import CoreData

@main
struct Main: App {
    let isTesting = NSClassFromString("XCTestCase") != nil

    var body: some Scene {
        WindowGroup {
            if self.isTesting {
                MockApp()
            } else {
                TimeARCApp()
            }
        }
    }
}

struct TimeARCApp: View {
    init() {
        #if DEBUG
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        #endif

        Resolver.register()

        do {
            let coreDataService: CoreDataService = Resolver.resolve()
            try coreDataService.loadAppState()
        } catch {
            fatalError("Error loading AppState: \(error.localizedDescription)")
        }
    }

    var body: some View {
        StoreProvider(store: store) {
            ContentView()
        }
    }
}

struct MockApp: View {
    init() {
        Resolver.registerMock()
    }

    var body: some View {
        Text("Testing...")
    }
}

// MARK: - Store

let store = Store<AppState>(reducer: appStateReducer,
                            middleware: [coreDataMiddleware,
                                         appIconMiddleware,
                                         notificationMiddleware,
                                         widgetUpdateMiddleware,
                                         watchCommunicationMiddleware],
                            state: AppState())

private func appStateReducer(state: AppState, action: Action) -> AppState {
    var newState = state

    switch action {
    case let action as InitAppState:
        newState = action.state
    default:
        newState.timeState = timeReducer(state: newState.timeState, action: action)
        newState.settingsState = settingsReducer(state: newState.settingsState, action: action)
        newState.statisticsState = statisticsReducer(appState: newState, action: action)
    }

    return newState
}

#if DEBUG
let previewStore = Store<AppState>(reducer: appStateReducer,
                                   middleware: [],
                                   state: appState())

private func appState() -> AppState {
    let url = Bundle.main.url(forResource: "appState", withExtension: "json")!
    let data = try! Data(contentsOf: url)
    let decodedState = try! JSONDecoder().decode(AppState.self, from: data)
    return decodedState
}
#endif

