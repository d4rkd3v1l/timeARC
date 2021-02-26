//
//  WatchCommunicator.swift
//  timeARC
//
//  Created by d4Rk on 18.09.20.
//

import WatchConnectivity
import SwiftUIFlux

class WatchCommunicator: NSObject, WCSessionDelegate {
    private let dispatch: DispatchFunction

    init(dispatch: @escaping DispatchFunction) {
        self.dispatch = dispatch
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
            self.dispatch(RequestWatchData())
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            self.dispatch(RequestWatchData())
        }
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        if let decodedData = try? JSONDecoder().decode(WatchToAppData.self, from: messageData) {
            self.dispatch(SyncTimeEntriesFromWatch(timeEntries: decodedData.timeEntries,
                                                           displayMode: decodedData.displayMode))
        }
    }
}
