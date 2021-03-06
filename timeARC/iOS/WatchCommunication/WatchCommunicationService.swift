//
//  WatchCommunicator.swift
//  timeARC
//
//  Created by d4Rk on 18.09.20.
//

import WatchConnectivity
import SwiftUIFlux
import Resolver

class WatchCommunicationService: NSObject, WCSessionDelegate {
    @Injected var dispatch: DispatchFunction

    override init() {
        super.init()

        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func requestWatchData() {
        let encodedData = try! JSONEncoder().encode("requestWatchData")
        WCSession.default.sendMessageData(encodedData, replyHandler: nil)
    }

    func sendDataToWatch(_ state: AppState) { // TODO: Optimize, by only sending new data, if actual relevant changes did happen
        DispatchQueue.global().async {
            let relevantTimeEntries = state.timeState.timeEntries.forDay(Day())
            let workingDays = state.settingsState.workingWeekDays.workingDays(startDate: Date(), endDate: Date())
            let isTodayWorkingDay = workingDays.contains(Day()) || !relevantTimeEntries.isEmpty

            let data = AppToWatchData(timeEntries: relevantTimeEntries,
                                      displayMode: state.timeState.displayMode,
                                      isTodayWorkingDay: isTodayWorkingDay,
                                      workingDuration: state.settingsState.workingDuration,
                                      accentColor: state.settingsState.accentColor)

            let encodedData = try! JSONEncoder().encode(data)
                DispatchQueue.main.async {
                    WCSession.default.sendMessageData(encodedData, replyHandler: nil)
                }

        }
    }

    // MARK: - WCSessionDelegate

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
