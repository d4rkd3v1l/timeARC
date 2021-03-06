//
//  CoreDataToStateService.swift
//  timeARC
//
//  Created by d4Rk on 28.02.21.
//

import SwiftUI
import SwiftUIFlux
import Resolver
import CoreData

class CoreDataToStateService {
    @LazyInjected private var dispatch: DispatchFunction

    func updateState(notification: NSNotification, context: NSManagedObjectContext, idMapping: [NSManagedObjectID: UUID]) {
        guard let userInfo = notification.userInfo else { return }

        // MARK: Insert
        if let insertedIds = userInfo[NSInsertedObjectIDsKey] as? Set<NSManagedObjectID>, !insertedIds.isEmpty {
            insertedIds.forEach { insertedId in
                let insertedObject = context.object(with: insertedId)

                switch insertedObject {
                case let managedTimeEntry as ManagedTimeEntry:
                    guard let timeEntry = TimeEntry(managedTimeEntry) else { fatalError() }
                    self.dispatch(AddTimeEntry(timeEntry: timeEntry, source: .remote))

                case let managedAbsenceEntry as ManagedAbsenceEntry:
                    guard let absenceEntry = AbsenceEntry(managedAbsenceEntry) else { fatalError() }
                    self.dispatch(AddAbsenceEntry(absenceEntry: absenceEntry, source: .remote))

                default:
                    break
                }
            }
        }

        // MARK: Update
        if let updatedIds = userInfo[NSUpdatedObjectIDsKey] as? Set<NSManagedObjectID>, !updatedIds.isEmpty {
            updatedIds.forEach { updatedId in
                let updatedObject = context.object(with: updatedId)

                switch updatedObject {
                case let managedTimeEntry as ManagedTimeEntry:
                    guard let timeEntry = TimeEntry(managedTimeEntry) else { fatalError() }
                    self.dispatch(UpdateTimeEntry(timeEntry: timeEntry, source: .remote))

                case let managedAbsenceEntry as ManagedAbsenceEntry:
                    guard let absenceEntry = AbsenceEntry(managedAbsenceEntry) else { fatalError() }
                    self.dispatch(UpdateAbsenceEntry(absenceEntry: absenceEntry, source: .remote))

                default:
                    break
                }
            }
        }

        // MARK: Delete
        if let deletedIds = userInfo[NSDeletedObjectIDsKey] as? Set<NSManagedObjectID>, !deletedIds.isEmpty {
            deletedIds.forEach { deletedId in
                let deletedObject = context.object(with: deletedId)

                switch deletedObject {
                case let managedTimeEntry as ManagedTimeEntry:
                    guard let id = idMapping[managedTimeEntry.objectID] else { return }
                    self.dispatch(DeleteTimeEntryById(id: id, source: .remote))

                case let managedAbsenceEntry as ManagedAbsenceEntry:
                    guard let id = idMapping[managedAbsenceEntry.objectID] else { return }
                    self.dispatch(DeleteAbsenceEntryById(id: id, source: .remote))

                default:
                    break
                }
            }
        }
    }
}
