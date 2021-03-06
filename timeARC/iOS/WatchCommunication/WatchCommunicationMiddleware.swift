//
//  WatchCommunicationMiddleware.swift
//  timeARC
//
//  Created by d4Rk on 01.03.21.
//

import SwiftUI
import SwiftUIFlux
import Resolver

let watchCommunicationMiddleware: Middleware<AppState> = { dispatch, getState in
    return { next in
        return { action in
            next(action)

            guard let state = getState() as? AppState else { return }

            switch action {
            case _ as InitAppState:
                _ = Resolver.resolve(WatchCommunicationService.self)

            case _ as RequestWatchData:
                let watchCommunicationService: WatchCommunicationService = Resolver.resolve()
                watchCommunicationService.requestWatchData()

            default:
                if state.timeState.didSyncWatchData {
                    let watchCommunicationService: WatchCommunicationService = Resolver.resolve()
                    watchCommunicationService.sendDataToWatch(state)
                }
            }
        }
    }
}
