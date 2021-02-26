//
//  App.swift
//  timeARC
//
//  Created by d4Rk on 18.07.20.
//

import SwiftUI
import SwiftUIFlux
import CoreData

@main
struct app: App {
    let cloudKitContainer = NSPersistentCloudKitContainer(name: "timeARC")
    let watchCommunicator = WatchCommunicator(dispatch: store.dispatch)

    init() {
        #if DEBUG
            print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        #endif

        self.initCoreData()
        self.initStore()
    }

    private func initCoreData() {
//        try? self.cloudKitContainer.initializeCloudKitSchema() // TODO: Remove before shipping the app?

        self.cloudKitContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }

    private func initStore() {
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

