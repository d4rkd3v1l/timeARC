//
//  WatchCommunicator.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 18.09.20.
//

import WatchConnectivity

class WatchCommunicator: NSObject, WCSessionDelegate {
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
        store.dispatch(action: RequestWatchData())
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            store.dispatch(action: RequestWatchData())
        }
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        if let decodedData = try? JSONDecoder().decode(WatchToAppData.self, from: messageData) {
            store.dispatch(action: SyncTimeEntriesFromWatch(timeEntries: decodedData.timeEntries))
            store.dispatch(action: ChangeTimerDisplayMode(displayMode: decodedData.displayMode))
        }
    }
}
