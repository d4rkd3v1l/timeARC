//
//  CoreDataMiddleware.swift
//  timeARC
//
//  Created by d4Rk on 27.02.21.
//

import SwiftUI
import SwiftUIFlux
import Resolver
import DifferenceKit
import CoreData

let coreDataMiddleware: Middleware<AppState> = { dispatch, getState in
    return { next in
        return { action in
            switch action {
            case is ToggleTimer,
                 is ActionWithSource where (action as! ActionWithSource).source == .local:
                let oldState = getState()
                next(action)
                let newState = getState()
                updateDiffableStuff(oldState: oldState, newState: newState)

            case is ChangeTimerDisplayMode,
                 is UpdateWorkingWeekDays,
                 is UpdateWorkingDuration,
                 is UpdateAccentColor:
                next(action)
                updateSettings(state: getState())

            default:
                next(action)
            }
        }
    }
}

private func updateDiffableStuff(oldState: FluxState?, newState: FluxState?) {
    guard let oldState = oldState as? AppState,
          let newState = newState as? AppState else { return }

    let stateToCoreDataService: StateToCoreDataService = Resolver.resolve()

    let oldTimeEntries = oldState.timeState.timeEntries.flatMap { $0.value }
    let newTimeEntries = newState.timeState.timeEntries.flatMap { $0.value }
    stateToCoreDataService.updateTimeEntries(oldTimeEntries: oldTimeEntries, newTimeEntries: newTimeEntries)

    let oldAbsenceEntries = oldState.timeState.absenceEntries
    let newAbsenceEntries = newState.timeState.absenceEntries
    stateToCoreDataService.updateAbsenceEntries(oldAbsenceEntries: oldAbsenceEntries, newAbsenceEntries: newAbsenceEntries)
}

private func updateSettings(state: FluxState?) {
    guard let state = state as? AppState else { return }

    let stateToCoreDataService: StateToCoreDataService = Resolver.resolve()

    stateToCoreDataService.updateSettings(displayMode: state.timeState.displayMode,
                                          workingWeekDays: state.settingsState.workingWeekDays,
                                          workingDuration: state.settingsState.workingDuration,
                                          accentColor: state.settingsState.accentColor)
}
