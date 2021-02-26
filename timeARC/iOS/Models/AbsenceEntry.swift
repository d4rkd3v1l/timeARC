//
//  AbsenceEntry.swift
//  timeARC
//
//  Created by d4Rk on 10.10.20.
//

import Foundation

struct AbsenceEntry: Identifiable, Equatable, Codable {
    private (set) var id = UUID()
    private (set) var lastModified: Date = Date()

    var type: AbsenceType {
        didSet {
            self.lastModified = Date()
        }
    }

    var start: Day {
        didSet {
            self.lastModified = Date()
        }
    }

    var end: Day {
        didSet {
            self.lastModified = Date()
        }
    }

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

    func relevantDays(for workingDays: [Day]) -> [Day] {
        return stride(from: self.start.date,
                      through: self.end.date,
                      by: 86400)
            .map { $0.day }
            .filter { workingDays.contains($0) }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.lastModified = (try container.decodeIfPresent(Date.self, forKey: .lastModified)) ?? Date()
        self.type = try container.decode(AbsenceType.self, forKey: .type)
        self.start = try container.decode(Day.self, forKey: .start)
        self.end = try container.decode(Day.self, forKey: .end)
    }
}

extension Array where Element == AbsenceEntry {
    func forDay(_ day: Day, workingDays: [Day]) -> [AbsenceEntry] {
        return self.filter { $0.relevantDays(for: workingDays).contains(day) }
    }

    /// Will produce "new" `AbsenceEntry`s that exactly match the provided range of days
    func exactAbsenceEntries(for workingDays: [Day],
                             from startDate: Date,
                             to endDate: Date) -> [AbsenceEntry] {
        let days = stride(from: startDate,
                          through: endDate,
                          by: 86400)
            .map { $0.day }
        let daysSet = Set(days)

        let newAbsenceEntries: [AbsenceEntry] = self.compactMap { absenceEntry in
            let absenceEntryRelevantDaysSet = Set<Day>(absenceEntry.relevantDays(for: workingDays))
            let intersection = [Day](absenceEntryRelevantDaysSet.intersection(daysSet)).sorted()

            guard let start = intersection.first,
                  let end = intersection.last else { return nil }

            return AbsenceEntry(type: absenceEntry.type,
                                start: start,
                                end: end)
        }

        return newAbsenceEntries
    }

    func totalDurationInSeconds(for workingDays: [Day], with workingDuration: Int) -> Int {
        return self.reduce(0) { total, current in
            let days = stride(from: current.start.date, through: current.end.date, by: 86400).map { $0 }
                .filter { workingDays.contains($0.day) }
            return total + Int((current.type.offPercentage * Float(workingDuration) * Float(days.count)))
        }
    }

    func totalDurationInDays(for workingDays: [Day]) -> Float {
        return self.reduce(0) { total, current in
            let days = stride(from: current.start.date, through: current.end.date, by: 86400).map { $0 }
                .filter { workingDays.contains($0.day) }
            return total + (current.type.offPercentage * Float(days.count))
        }
    }

    func totalDurationInDaysByType(for workingDays: [Day]) -> [AbsenceType: Float] {
        return Dictionary(grouping: self, by: { $0.type })
            .mapValues { $0.totalDurationInDays(for: workingDays) }
    }
}
