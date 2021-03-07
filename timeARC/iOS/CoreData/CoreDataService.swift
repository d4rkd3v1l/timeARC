//
//  CoreDataManager.swift
//  timeARC
//
//  Created by d4Rk on 26.02.21.
//

import Resolver
import CoreData
import SwiftUIFlux

enum CoreDataError: Error {
    case couldNotFetchManagedObject
    case couldNotInsertManagedObject
    case couldNotUpdateManagedObject
    case couldNotDeleteManagedObject
}

class CoreDataService {
    private let persistentContainer = NSPersistentCloudKitContainer(name: "timeARC")

    @Injected private var coreDataToStateService: CoreDataToStateService
    @LazyInjected private var dispatch: DispatchFunction

    // Note: Needed for deletions from iCloud, as we only receive the ManagedObjectID in that case
    private var idMapping: [NSManagedObjectID: UUID] = [:]


    private var initialCloudKitEvents: Set<NSPersistentCloudKitContainer.EventType> = Set()
    private var initialSyncCompleted: Bool {
        return self.initialCloudKitEvents.contains(.setup)
            && self.initialCloudKitEvents.contains(.import)
            && self.initialCloudKitEvents.contains(.export)
    }

    private var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }

    init(inMemory: Bool = false) {
        if inMemory {
            self.persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        self.persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        // Note: This bascially does all the sync magic
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        self.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.eventChangedNotification),
                                               name: NSPersistentCloudKitContainer.eventChangedNotification,
                                               object: self.persistentContainer)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didSaveObjectsNotification),
                                               name: NSManagedObjectContext.didSaveObjectsNotification,
                                               object: self.persistentContainer.viewContext)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didMergeChangesObjectIDsNotification),
                                               name: NSManagedObjectContext.didMergeChangesObjectIDsNotification,
                                               object: self.persistentContainer.viewContext)
    }

    // MARK: - Load App State

    // TODO: Get rid of force unwraps?
    func loadAppState() throws {
        let timeEntries = try self.loadTimeEntries()
        let absenceEntries = try self.loadAbsenceEntries()

        let managedSettings: ManagedSettings = try self.fetchAll().first ?? (try ManagedSettings.newSettings(with: self.context))

        let timerDisplayMode = TimerDisplayMode(rawValue: managedSettings.timerDisplayMode!)!

        let timeState = TimeState(timeEntries: timeEntries,
                                  absenceEntries: absenceEntries,
                                  displayMode: timerDisplayMode,
                                  didSyncWatchData: false)

        let workingWeekDays = managedSettings.workingWeekDays!
            .map(WeekDay.init)

        let workingDuration = Int(managedSettings.workingDuration)
        let accentColor = CodableColor(rawValue: managedSettings.accentColor!)!

        let absenceTypes = managedSettings.absenceTypes?
            .compactMap { $0 as? ManagedAbsenceType }
            .compactMap(AbsenceType.init) ?? []

        let settingsState = SettingsState(workingWeekDays: workingWeekDays,
                                          workingDuration: workingDuration,
                                          accentColor: accentColor,
                                          absenceTypes: absenceTypes)

        let statisticsState = StatisticsState()

        let appState = AppState(isAppStateLoading: false,
                                timeState: timeState,
                                settingsState: settingsState,
                                statisticsState: statisticsState)

        self.dispatch(InitAppState(state: appState))
    }

    private func loadTimeEntries() throws -> [Day: [TimeEntry]] {
        let managedTimeEntries: [ManagedTimeEntry] = try self.fetchAll()
        let timeEntriesArray: [TimeEntry] = managedTimeEntries
            .compactMap(TimeEntry.init)
        let timeEntries = Dictionary(grouping: timeEntriesArray, by: { $0.start.day })
        return timeEntries
    }

    private func loadAbsenceEntries() throws -> [AbsenceEntry] {
        let managedAbsenceEntries: [ManagedAbsenceEntry] = try self.fetchAll()
        let absenceEntries: [AbsenceEntry] = managedAbsenceEntries
            .compactMap(AbsenceEntry.init)
        return absenceEntries
    }

    // MARK: - Specifics

    func insert(timeEntry: TimeEntry) throws {
        let managedTimeEntry = ManagedTimeEntry(context: self.context)
        managedTimeEntry.id = timeEntry.id
        managedTimeEntry.start = timeEntry.start
        managedTimeEntry.end = timeEntry.end

        try self.context.save()
    }

    func update(timeEntry: TimeEntry) throws {
        guard let managedTimeEntry: ManagedTimeEntry = try? self.fetch(id: timeEntry.id) else {
            throw CoreDataError.couldNotFetchManagedObject
        }
        managedTimeEntry.start = timeEntry.start
        managedTimeEntry.end = timeEntry.end

        try self.context.save()
    }

    func insert(absenceEntry: AbsenceEntry) throws {
        let managedAbsenceEntry = ManagedAbsenceEntry(context: self.context)

        // TODO: Check if there is a generic solution for relationships
        guard let managedAbsenceType: ManagedAbsenceType = try? self.fetch(id: absenceEntry.type.id) else {
            throw CoreDataError.couldNotFetchManagedObject
        }

        managedAbsenceEntry.id = absenceEntry.id
        managedAbsenceEntry.type = managedAbsenceType
        managedAbsenceEntry.start = absenceEntry.start.date
        managedAbsenceEntry.end = absenceEntry.end.date

        try self.context.save()
    }

    func update(absenceEntry: AbsenceEntry) throws {
        guard let managedAbsenceEntry: ManagedAbsenceEntry = try? self.fetch(id: absenceEntry.id) else {
            throw CoreDataError.couldNotFetchManagedObject
        }

        // TODO: Check if there is a generic solution for relationships
        guard let managedAbsenceType: ManagedAbsenceType = try? self.fetch(id: absenceEntry.type.id) else {
            throw CoreDataError.couldNotFetchManagedObject
        }

        managedAbsenceEntry.type = managedAbsenceType
        managedAbsenceEntry.start = absenceEntry.start.date
        managedAbsenceEntry.end = absenceEntry.end.date

        try self.context.save()
    }

    func updateSettings(_ performUpdate: ((ManagedSettings) -> Void)) throws {
        guard let managedSettings: ManagedSettings = try self.fetchAll().first else { fatalError() }
        performUpdate(managedSettings)
        try self.context.save()
    }

    // MARK: - Generics

    func fetch<ManagedObject: FetchableById>(id: UUID) throws -> ManagedObject {
        let fetchRequest: NSFetchRequest<ManagedObject> = ManagedObject.fetchRequest() as! NSFetchRequest<ManagedObject>
        fetchRequest.predicate = NSPredicate(format: "id = %@", id as CVarArg)

        guard let managedObject = try self.context.fetch(fetchRequest).first else { throw CoreDataError.couldNotFetchManagedObject }
        return managedObject
    }

    func fetchAll<ManagedObject: NSManagedObject>() throws -> [ManagedObject] {
        let fetchRequest: NSFetchRequest<ManagedObject> = ManagedObject.fetchRequest() as! NSFetchRequest<ManagedObject>
        return try self.context.fetch(fetchRequest)
    }

    func insert<ManagedObject: FetchableById>(performInit: ((ManagedObject) -> Void)) throws {
        let managedObject = ManagedObject(context: self.context)
        performInit(managedObject)
        try self.context.save()
    }

    func update<ManagedObject: FetchableById>(id: UUID, performUpdate: ((ManagedObject) -> Void)) throws {
        let managedObject: ManagedObject = try self.fetch(id: id)
        performUpdate(managedObject)
        try self.context.save()
    }

    func delete<ManagedObject: FetchableById>(_ type: ManagedObject.Type, id: UUID) throws  {
        let managedObject: ManagedObject = try self.fetch(id: id)
        self.context.delete(managedObject)
        try self.context.save()
    }

    // MARK: - Notifications

    // Inspired by https://stackoverflow.com/a/63927190/2019384
    @objc private func eventChangedNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let eventNotification = userInfo[NSPersistentCloudKitContainer.eventNotificationUserInfoKey],
              let cloudEvent = eventNotification as? NSPersistentCloudKitContainer.Event,
              cloudEvent.endDate != nil else { return }

        // TODO: Remove before release ;-)
        if let error = cloudEvent.error {
            fatalError(error.localizedDescription)
        }

        self.initialCloudKitEvents.insert(cloudEvent.type)
    }

    @objc private func didSaveObjectsNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }

        if let insertedObjects = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, !insertedObjects.isEmpty {
            insertedObjects.forEach { insertedObject in
                switch insertedObject {
                case let managedTimeEntry as ManagedTimeEntry:
                    self.idMapping[managedTimeEntry.objectID] = managedTimeEntry.id

                case let managedAbsenceEntry as ManagedAbsenceEntry:
                    self.idMapping[managedAbsenceEntry.objectID] = managedAbsenceEntry.id

                default:
                    break
                }
            }
        }

        // TODO: also delete?!
    }

    @objc private func didMergeChangesObjectIDsNotification(notification: NSNotification) {
        try? self.singletonifySettings(notification: notification)
        self.coreDataToStateService.updateState(notification: notification,
                                                context: self.context,
                                                idMapping: self.idMapping)
    }

    private func singletonifySettings(notification: NSNotification) throws {
//        guard let userInfo = notification.userInfo,
//              let insertedIds = userInfo[NSInsertedObjectIDsKey] as? Set<NSManagedObjectID>,
//              !insertedIds.isEmpty else { return }
//
//        let newManagedSettingsInstances = insertedIds.compactMap { self.context.object(with: $0) as? ManagedSettings }
//        guard !newManagedSettingsInstances.isEmpty else { return }

        let localManagedSettingsInstances: [ManagedSettings] = try self.fetchAll()
        guard localManagedSettingsInstances.count > 1 else { return }

        // TODO: Improve "algorithm" -> delete the oldest/newest or least recently changed ones?
        localManagedSettingsInstances.dropLast().forEach { instance in
            self.context.delete(instance)
        }

        try self.context.save()
    }
}