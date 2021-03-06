//
//  TimerMiddleware.swift
//  timeARC
//
//  Created by d4Rk on 20.07.20.
//

import SwiftUI
import SwiftUIFlux
import Resolver

let appIconMiddleware: Middleware<AppState> = { dispatch, getState in
    return { next in
        return { action in
            next(action)

            switch action {
            case let action as UpdateAccentColor:
                updateAppIcon(with: action.color.color(for: action.colorScheme),
                              for: action.colorScheme)

            default:
                break
            }
        }
    }
}

// MARK: - App Icon

private func updateAppIcon(with color: Color, for colorScheme: ColorScheme) {
    let iconName = "icon_\(colorScheme)_\(color)"
    UIApplication.shared.setAlternateIconName(iconName)
}
