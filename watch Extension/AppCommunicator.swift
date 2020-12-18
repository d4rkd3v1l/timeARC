//
//  AppCommunicator.swift
//  watch Extension
//
//  Created by d4Rk on 18.09.20.
//

import WatchConnectivity

class AppCommunicator: NSObject, WCSessionDelegate {
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
                                                displayMode: decodedData.displayMode,
                                                isTodayWorkingDay: decodedData.isTodayWorkingDay,
                                                workingDuration: decodedData.workingDuration,
                                                accentColor: decodedData.accentColor))
        } else if let decodedData = try? JSONDecoder().decode(String.self, from: messageData) {
            switch decodedData {
            case "requestWatchData":
                store.dispatch(action: SendDataToApp())

            default:
                break
            }
        }
    }
}
