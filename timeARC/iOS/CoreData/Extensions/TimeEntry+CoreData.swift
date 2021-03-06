//
//  TimeEntry+CoreData.swift
//  timeARC
//
//  Created by d4Rk on 05.03.21.
//

extension TimeEntry {
    init?(_ managedTimeEntry: ManagedTimeEntry) {
        guard let id = managedTimeEntry.id,
              let start = managedTimeEntry.start else { return nil }

        self.init(id: id, start: start, end: managedTimeEntry.end)
    }
}
