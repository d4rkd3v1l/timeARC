//
//  WatchMiddleware.swift
//  watch Extension
//
//  Created by d4Rk on 29.08.20.
//

import SwiftUIFlux
import WatchConnectivity
import ClockKit

let watchMiddleware: Middleware<WatchState> = { dispatch, getState in
    return { next in
        return { action in
            next(action)

            if !(action is SetWatchData),
               let state = getState() as? WatchState {
                sendDataToApp(state)
            }

            updateAllComplications()
        }
    }
}

private func sendDataToApp(_ state: WatchState) {
    DispatchQueue.global().async {
        let data = WatchToAppData(timeEntries: state.timeEntries)

        if let encodedData = try? JSONEncoder().encode(data) {
            DispatchQueue.main.async {
                WCSession.default.sendMessageData(encodedData, replyHandler: nil)
            }
        }
    }
}

private func updateAllComplications() {
    let complicationServer = CLKComplicationServer.sharedInstance()
    complicationServer.activeComplications?.forEach { complication in
        complicationServer.reloadTimeline(for: complication)
    }
}
