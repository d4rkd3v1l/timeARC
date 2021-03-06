//
//  AbsenceEntry+CoreData.swift
//  timeARC
//
//  Created by d4Rk on 05.03.21.
//

extension AbsenceEntry {
    init?(_ managedAbsenceEntry: ManagedAbsenceEntry) {
        guard let id = managedAbsenceEntry.id,
              let managedAbsenceEntryType = managedAbsenceEntry.type,
              let type = AbsenceType(managedAbsenceEntryType),
              let start = managedAbsenceEntry.start,
              let end = managedAbsenceEntry.end else { return nil }

        self.init(id: id, type: type, start: start.day, end: end.day)
    }
}
