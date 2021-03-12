//
//  App+Injection.swift
//  timeARC
//
//  Created by d4Rk on 28.02.21.
//

import Resolver
import SwiftUIFlux

extension Resolver {
    static func register() {
        register { store.dispatch }.scope(.application)
        register { CoreDataService() }.scope(.application)
        register { CoreDataToStateService() }
        register { StateToCoreDataService() }
        register { WatchCommunicationService() }.scope(.application)
        register { WidgetUpdateService() }
        register { NotificationService() }
    }

    static func registerMock() {
        register { { _ in } as DispatchFunction }.scope(.application)
        register { CoreDataService(inMemory: true) }.scope(.application)
        register { CoreDataToStateService() }
        register { StateToCoreDataService() }
        register { NotificationService() }
    }
}
