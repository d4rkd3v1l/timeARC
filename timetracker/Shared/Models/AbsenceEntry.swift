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
    private (set) var startDate: Date
    private (set) var endDate: Date

    init(type: AbsenceType, startDate: Date, endDate: Date) {
        self.type = type
        self.startDate = startDate.startOfDay
        self.endDate = endDate.startOfDay
    }

    mutating func update(type: AbsenceType, startDate: Date, endDate: Date) {
        self.type = type
        self.startDate = startDate.startOfDay
        self.endDate = endDate.startOfDay
    }

    func isRelevantFor(day: Date) -> Bool {
        let range = stride(from: self.startDate,
                           through: self.endDate,
                           by: 86400)
            .map { $0 }

        return range.contains(day.startOfDay)
    }

    static func == (lhs: AbsenceEntry, rhs: AbsenceEntry) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Array where Element == AbsenceEntry {
    func absenceEntriesFor(day: Date) -> [AbsenceEntry] {
        return self.filter { $0.isRelevantFor(day: day) }
    }
}
