//
//  AbsenceEntry.swift
//  timetracker
//
//  Created by d4Rk on 10.10.20.
//

import Foundation

struct AbsenceEntry: Identifiable, Equatable, Hashable, Codable {
    private (set) var id = UUID()
    private (set) var type: AbsenceType
    private (set) var start: Day
    private (set) var end: Day

    init(type: AbsenceType, start: Day, end: Day) {
        self.type = type
        self.start = start
        self.end = end
    }

    mutating func update(type: AbsenceType, start: Day, end: Day) {
        self.type = type
        self.start = start
        self.end = end
    }

    var relevantDays: [Day] {
        return stride(from: self.start.date,
                      through: self.end.date,
                      by: 86400)
            .map { $0.day }
    }

    static func == (lhs: AbsenceEntry, rhs: AbsenceEntry) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Array where Element == AbsenceEntry {
    func absenceEntriesFor(day: Day) -> [AbsenceEntry] {
        return self.filter { $0.relevantDays.contains(day) }
    }
}
