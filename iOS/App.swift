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

        AppCommunicator.shared

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

import WatchConnectivity

class AppCommunicator: NSObject, WCSessionDelegate {
    static let shared = AppCommunicator()

    override init() {
        super.init()

        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("APP: sessionDidBecomeInactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("APP: sessionDidDeactivate")
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("APP: activationDidCompleteWith: \(activationState.rawValue), error: \(error?.localizedDescription ?? "no error")")
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        if let decodedData = try? JSONDecoder().decode(WatchToAppData.self, from: messageData) {
            store.dispatch(action: SyncTimeEntriesFromWatch(timeEntries: decodedData.timeEntries))
        }
    }
}
