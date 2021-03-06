//
//  NotificationMiddleware.swift
//  timeARC
//
//  Created by d4Rk on 01.03.21.
//

import SwiftUI
import SwiftUIFlux
import Resolver

let notificationMiddleware: Middleware<AppState> = { dispatch, getState in
    return { next in
        return { action in
            next(action)

            guard let state = getState() as? AppState  else { return }

            let notificationService: NotificationService = Resolver.resolve()
            if state.timeState.timeEntries.isTimerRunning {
                notificationService.scheduleEndOfWorkingDayNotification(for: state.timeState.timeEntries,
                                                                        workingDuration: state.settingsState.workingDuration)

                notificationService.scheduleEndOfWorkingWeekNotification(for: state.timeState.timeEntries,
                                                                         workingDuration: state.settingsState.workingDuration,
                                                                         workingWeekDays: state.settingsState.workingWeekDays)
            } else {
                notificationService.removeNotifications(identifiers: [NotificationService.endOfWoringDayNotificationIdentifier,
                                                                      NotificationService.endOfWoringWeekNotificationIdentifier])
            }
        }
    }
}
