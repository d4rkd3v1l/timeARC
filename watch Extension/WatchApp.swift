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
    let initAppComm = AppCommunicator.shared // TODO: Make this more elegant?

    @SceneBuilder var body: some Scene {
        WindowGroup {
            StoreProvider(store: store) {
                ContentView()
            }
        }
        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
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

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WATCH: activationDidCompleteWith: \(activationState.rawValue), error: \(error?.localizedDescription ?? "no error")")
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        if let decodedData = try? JSONDecoder().decode(AppToWatchData.self, from: messageData) {
            store.dispatch(action: SetWatchData(timeEntries: decodedData.timeEntries,
                                                workingMinutesPerDay: decodedData.workingMinutesPerDay))
        }
    }
}
