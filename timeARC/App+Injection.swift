//
//  App+Injection.swift
//  timeARC
//
//  Created by d4Rk on 28.02.21.
//

import Resolver
import SwiftUIFlux
import CoreData

extension Resolver {
    static func register(store: Store<AppState>) {
        register { store.dispatch }.scope(.application)
        register { NSPersistentCloudKitContainer(name: "timeARC") as NSPersistentContainer }.scope(.application)
        register { CoreDataService() }.scope(.application)
        register { CoreDataToStateService() }
        register { StateToCoreDataService() }
        register { WatchCommunicationService() }.scope(.application)
        register { WidgetUpdateService() }
        register { NotificationService() }
    }

    static func registerMock() {
        register { { _ in } as DispatchFunction }.scope(.application)
        register { _ -> NSPersistentContainer in
            let mockContainer = NSPersistentContainer(name: "timeARC")
            mockContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            return mockContainer
        }.scope(.application)
        register { CoreDataService() }.scope(.application)
        register { CoreDataToStateService() }
        register { StateToCoreDataService() }
        register { NotificationService() }
    }
}
