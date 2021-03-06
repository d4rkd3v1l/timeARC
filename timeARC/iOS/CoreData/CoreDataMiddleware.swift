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
//            case is InitAppState,
//                 is ActionWithSource where (action as! ActionWithSource).source == .remote:
//                next(action)
//
//            default:
//                let oldState = getState()
//                next(action)
//                let newState = getState()
//                updateCoreData(oldState: oldState, newState: newState)
//            }

            case is ToggleTimer,
                 is ActionWithSource where (action as! ActionWithSource).source == .local:
                let oldState = getState()
                next(action)
                let newState = getState()
                updateCoreData(oldState: oldState, newState: newState)

            default:
                next(action)
            }
        }
    }
}

private func updateCoreData(oldState: FluxState?, newState: FluxState?) {
    guard let oldState = oldState as? AppState,
          let newState = newState as? AppState else { return }

    let stateToCoreDataService: StateToCoreDataService = Resolver.resolve()

    let oldTimeEntries = oldState.timeState.timeEntries.flatMap { $0.value }
    let newTimeEntries = newState.timeState.timeEntries.flatMap { $0.value }
    stateToCoreDataService.applyChanges(oldTimeEntries: oldTimeEntries, newTimeEntries: newTimeEntries)

    let oldAbsenceEntries = oldState.timeState.absenceEntries
    let newAbsenceEntries = newState.timeState.absenceEntries
    stateToCoreDataService.applyChanges(oldAbsenceEntries: oldAbsenceEntries, newAbsenceEntries: newAbsenceEntries)
}
