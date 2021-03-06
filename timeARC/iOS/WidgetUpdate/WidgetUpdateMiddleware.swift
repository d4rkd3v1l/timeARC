//
//  WidgetUpdateMiddleware.swift
//  timeARC
//
//  Created by d4Rk on 01.03.21.
//

import SwiftUI
import SwiftUIFlux
import Resolver

let widgetUpdateMiddleware: Middleware<AppState> = { dispatch, getState in
    return { next in
        return { action in
            next(action)

            guard let state = getState() as? AppState else { return }

            let widgetService: WidgetUpdateService = Resolver.resolve()
            widgetService.updateWidgets(state)
        }
    }
}
