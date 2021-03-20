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
    let isRunningUnitTests = NSClassFromString("XCTestCase") != nil
    let isRunningUITests = ProcessInfo().arguments.contains("--UITests")

    init() {
        if self.isRunningUnitTests {
            Resolver.registerUnitTestMocks()
        } else if self.isRunningUITests {
            Resolver.registerUITestMocks(store: store)
        } else {
            Resolver.register(store: store)
        }
    }

    var body: some Scene {
        WindowGroup {
            if self.isRunningUnitTests {
                UnitTestApp()
            } else {
                TimeARCApp()
            }
        }
    }
}

struct UnitTestApp: View {
    var body: some View {
        Text("Running unit tests...")
    }
}

struct TimeARCApp: View {
    init() {
        #if DEBUG
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        #endif

        do {
            let coreDataService: CoreDataService = Resolver.resolve()
            let dispatch: DispatchFunction = Resolver.resolve()

            let appState = try coreDataService.loadAppState()
            dispatch(InitAppState(state: appState))
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

// MARK: - Store

private let store = Store<AppState>(reducer: appStateReducer,
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
let testStore = Store<AppState>(reducer: appStateReducer,
                                middleware: [],
                                state: AppState())

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

