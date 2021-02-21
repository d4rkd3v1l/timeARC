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
    let watchCommunicator = WatchCommunicator(dispatch: store.dispatch)

    init() {
        #if DEBUG
            print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        #endif
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

// MARK: - Store

private let store = Store<AppState>(reducer: appStateReducer,
                            middleware: [globalMiddleware],
                            state: AppState())

private func appStateReducer(state: AppState, action: Action) -> AppState {
    var newState: AppState
    switch action {

    case _ as AppStateLoadingInProgress:
        newState = AppState()
        newState.isAppStateLoading = true

    case let action as AppStateLoadingSuccess:
        newState = action.state
        newState.isAppStateLoading = false

    default:
        newState = state
    }

    newState.timeState = timeReducer(state: newState.timeState, action: action)
    newState.settingsState = settingsReducer(state: newState.settingsState, action: action)
    newState.statisticsState = statisticsReducer(appState: newState, action: action)
    return newState
}

#if DEBUG
let previewStore = Store<AppState>(reducer: appStateReducer,
                                   middleware: [globalMiddleware],
                                   state: appState())

private func appState() -> AppState {
    let url = Bundle.main.url(forResource: "appState", withExtension: "json")!
    let data = try! Data(contentsOf: url)
    let decodedState = try! JSONDecoder().decode(AppState.self, from: data)
    return decodedState
}
#endif

