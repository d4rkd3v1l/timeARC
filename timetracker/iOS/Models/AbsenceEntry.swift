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
    func absenceEntries(for day: Day) -> [AbsenceEntry] {
        return self.filter { $0.relevantDays.contains(day) }
    }

    /// Will produce "new" `AbsenceEntry`s that exactly match the provided range of days
    func exactAbsenceEntries(from startDate: Date,
                             to endDate: Date) -> [AbsenceEntry] {
        let days = stride(from: startDate,
                          through: endDate,
                          by: 86400)
            .map { $0.day }
        let daysSet = Set(days)

        let newAbsenceEntries: [AbsenceEntry] = self.compactMap { absenceEntry in
            let absenceEntryRelevantDaysSet = Set<Day>(absenceEntry.relevantDays)
            let intersection = [Day](absenceEntryRelevantDaysSet.intersection(daysSet)).sorted()

            guard let start = intersection.first,
                  let end = intersection.last else { return nil }

            return AbsenceEntry(type: absenceEntry.type,
                                start: start,
                                end: end)
        }

        return newAbsenceEntries
    }

    func totalDurationInSeconds(with workingDuration: Int) -> Int {
        return self.reduce(0) { total, current in
            let days = stride(from: current.start.date, through: current.end.date, by: 86400).map { $0 }
            return total + Int((current.type.offPercentage * Float(workingDuration) * Float(days.count)))
        }
    }

    func totalDurationInDays() -> Float {
        return self.reduce(0) { total, current in
            let days = stride(from: current.start.date, through: current.end.date, by: 86400).map { $0 }
            return total + (current.type.offPercentage * Float(days.count))
        }
    }

    func totalDurationInDaysByType() -> [AbsenceType: Float] {
        return Dictionary(grouping: self, by: { $0.type })
            .mapValues { $0.totalDurationInDays() }
    }
}
