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
        WCSession.default.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            store.dispatch(action: RequestWatchData())
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            store.dispatch(action: RequestWatchData())
        }
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        if let decodedData = try? JSONDecoder().decode(WatchToAppData.self, from: messageData) {
            store.dispatch(action: SyncTimeEntriesFromWatch(timeEntries: decodedData.timeEntries,
                                                            displayMode: decodedData.displayMode))
        }
    }
}
