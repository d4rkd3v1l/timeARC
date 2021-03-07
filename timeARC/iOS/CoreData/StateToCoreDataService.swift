//
//  CoreDataBridgeService.swift
//  timeARC
//
//  Created by d4Rk on 28.02.21.
//

import Foundation
import Resolver
import DifferenceKit

class StateToCoreDataService {
    @Injected private var coreDataService: CoreDataService

    // MARK: - TimeEntry

    func updateTimeEntries(oldTimeEntries: [TimeEntry], newTimeEntries: [TimeEntry]) {
        let stagedChangeset = StagedChangeset(source: oldTimeEntries, target: newTimeEntries)

        for changeset in stagedChangeset {
            for inserted in changeset.elementInserted {
                let newTimeEntry = newTimeEntries[inserted.element]
                try? self.coreDataService.insert(timeEntry: newTimeEntry)
            }

            for updated in changeset.elementUpdated {
                let updatedTimeEntry = newTimeEntries[updated.element]
                try? self.coreDataService.update(timeEntry: updatedTimeEntry)
            }

            for deleted in changeset.elementDeleted {
                let deletedTimeEntry = oldTimeEntries[deleted.element]
                try? self.coreDataService.delete(ManagedTimeEntry.self, id: deletedTimeEntry.id)
            }
        }
    }

    // MARK: - AbsenceEntry

    func updateAbsenceEntries(oldAbsenceEntries: [AbsenceEntry], newAbsenceEntries: [AbsenceEntry]) {
        let stagedChangeset = StagedChangeset(source: oldAbsenceEntries, target: newAbsenceEntries)

        for changeset in stagedChangeset {
            for inserted in changeset.elementInserted {
                let newAbsenceEntry = newAbsenceEntries[inserted.element]
                try? self.coreDataService.insert(absenceEntry: newAbsenceEntry)
            }

            for updated in changeset.elementUpdated {
                let updatedAbsenceEntry = newAbsenceEntries[updated.element]
                try? self.coreDataService.update(absenceEntry: updatedAbsenceEntry)
            }

            for deleted in changeset.elementDeleted {
                let deletedAbsenceEntry = oldAbsenceEntries[deleted.element]
                try? self.coreDataService.delete(ManagedAbsenceEntry.self, id: deletedAbsenceEntry.id)
            }
        }
    }

    // MARK: - Misc

    func updateSettings(displayMode: TimerDisplayMode,
                        workingWeekDays: [WeekDay],
                        workingDuration: Int,
                        accentColor: CodableColor) {
        try! self.coreDataService.updateSettings { managedSettings in
            managedSettings.timerDisplayMode = displayMode.rawValue
            managedSettings.workingWeekDays = workingWeekDays.map { $0.rawValue }
            managedSettings.workingDuration = Int64(workingDuration)
            managedSettings.accentColor = accentColor.rawValue
        }
    }
}

// MARK: - Extensions

extension TimeEntry: Differentiable {
    var differenceIdentifier: UUID {
        self.id
    }

    func isContentEqual(to source: Self) -> Bool {
        self == source
    }
}

extension AbsenceEntry: Differentiable {
    var differenceIdentifier: UUID {
        self.id
    }

    func isContentEqual(to source: Self) -> Bool {
        self == source
    }
}
