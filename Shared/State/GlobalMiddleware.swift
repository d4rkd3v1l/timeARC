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
            return next(action)
        }
    }
}
