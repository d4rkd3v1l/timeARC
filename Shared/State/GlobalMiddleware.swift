//
//  TimerMiddleware.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import SwiftUI
import SwiftUIFlux

let globalMiddleware: Middleware<AppState> = { dispatch, getState in
    return { next in
        return { action in
            next(action)

            if let state = getState() as? AppState {
                saveAppState(state) // TODO: optimize, don't do this for any action?
            }
        }
    }
}
