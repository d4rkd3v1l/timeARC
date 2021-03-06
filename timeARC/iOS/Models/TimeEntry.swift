//
//  TimeEntry.swift
//  timeARC
//
//  Created by d4Rk on 20.07.20.
//

import SwiftUI

struct TimeEntry: Identifiable, Equatable, Codable {
    private (set) var id = UUID()
    private (set) var lastModified: Date = Date()

    var start: Date {
        didSet {
            self.lastModified = Date()
        }
    }

    var end: Date? {
        didSet {
            self.lastModified = Date()
        }
    }

    init(start: Date = Date(), end: Date? = nil) {
        self.start = start
        self.end = end
    }

    mutating func stop() {
        self.end = Date()
    }

    // MARK: Helper

    var isRunning: Bool {
        return self.end == nil
    }

    var actualEnd: Date {
        return self.end ?? Date()
    }

    func durationFormatted(allowedUnits: NSCalendar.Unit = [.hour, .minute]) -> String? {
        return self.start.durationFormatted(until: self.actualEnd, allowedUnits: allowedUnits)
    }

    var durationInSeconds: Int? {
        return Calendar.current
            .dateComponents([.second], from: self.start, to: self.actualEnd)
            .second
    }

    func splittedIntoSingleDays() -> [TimeEntry] {
        guard self.start.startOfDay != self.actualEnd.startOfDay else { return [self] }

        let range = stride(from: self.start.startOfDay,
                           through: self.actualEnd.startOfDay,
                           by: 86400)
            .map { $0 }

        let timeEntries: [TimeEntry] = range
            .enumerated()
            .map { (index, date) in
                switch index {
                case 0:
                    var newTimeEntry = self
                    newTimeEntry.end = self.start.endOfDay
                    return newTimeEntry

                case (range.count - 1):
                    return TimeEntry(start: date.startOfDay, end: self.end)

                default:
                    return TimeEntry(start: date.startOfDay, end: date.endOfDay)
                }
            }

        return timeEntries
    }
}

// MARK: - Extensions

extension Dictionary where Key == Day, Value == [TimeEntry] {
    func forDay(_ day: Day) -> [TimeEntry] {
        return self[day] ?? []
    }

    func find(_ timeEntry: TimeEntry) -> TimeEntry? { 
        // Optimization, works as long as start day did not change
        if let timeEntriesForDay = self[timeEntry.start.day],
            let timeEntry = timeEntriesForDay.first(where: { $0.id == timeEntry.id }) {
            return timeEntry
        }

        // Fallback, if start day did change (have to go through all the entries in this case)
        return self.values
            .flatMap { $0 }
            .first(where: { $0.id == timeEntry.id })
    }
    
    var isTimerRunning: Bool {
        return self.forDay(Day()).isTimerRunning
    }

    // MARK: Statistics
    func timeEntries(from startDate: Date,
                     to endDate: Date) -> [Day: [TimeEntry]] {
        let range = (startDate.startOfDay...endDate.endOfDay)
        return self.filter { range.contains($0.key.date) }
    }

    func averageDuration() -> Int {
        return self
            .mapValues { $0.totalDurationInSeconds }
            .values
            .compactMap { $0 }
            .average()
    }

    func totalDuration() -> Int {
        return self
            .mapValues { $0.totalDurationInSeconds }
            .values
            .compactMap { $0 }
            .sum()
    }

    func averageWorkingHoursStartDate() -> Date {
        return self
            .compactMap { _, timeEntries in
                timeEntries.first?.start
            }
            .averageTime
    }

    func averageWorkingHoursEndDate() -> Date {
        return self
            .compactMap { _, timeEntries in
                timeEntries.last?.end
            }
            .averageTime
    }

    private func totalBreaksDurations() -> [Int] {
        return self
            .map { _, entries in entries.totalBreaksInSeconds }
    }

    func averageBreaksDuration() -> Int {
        return self.totalBreaksDurations()
            .average()
    }

    func totalBreaksDuration() -> Int {
        return self.totalBreaksDurations()
            .sum()
    }

    func averageOvertimeDuration(workingDuration: Int) -> Int {
        return self.averageDuration() - workingDuration
    }

    func totalOvertimeDuration(workingDays: [Day],
                               workingDuration: Int,
                               absenceEntries: [AbsenceEntry]) -> Int {
        let absenceDuration = workingDays.map { day in
            absenceEntries.forDay(day, workingDays: workingDays).reduce(0) { $0 + Int($1.type.offPercentage * Float(workingDuration)) }
        }
        .sum()

        return self.totalDuration() + absenceDuration - (workingDuration * workingDays.count)
    }
}

extension Array where Element == TimeEntry {
    var totalDurationInSeconds: Int {
        return self
            .compactMap { $0.durationInSeconds }
            .reduce(0, +)
    }

    var totalBreaksInSeconds: Int {
        guard !self.isEmpty else { return 0 }

        var result = 0

        for index in 0..<(self.count-1) {
            let current = self[index]
            let next = self[index+1]

            let currentAbsoluteEnd = Int(current.actualEnd.timeIntervalSince(current.actualEnd.startOfDay))
            let nextAbsoluteStart = Int(next.start.timeIntervalSince(next.start.startOfDay))

            let difference = nextAbsoluteStart - currentAbsoluteEnd

            if difference > 0 {
                result += difference
            }
        }

        return result
    }

    var isTimerRunning: Bool {
        return self.contains(where: { $0.isRunning })
    }

    func mergedOverlappingEntries() -> [TimeEntry] {
        var merged = self.sorted(by: { $0.start < $1.start })
        var index: Int = 0

        for _ in 0..<merged.count {
            guard index < (merged.count - 1) else { break }

            let current = merged[index]
            let next = merged[index+1]

            if current.actualEnd >= next.start {
                merged.removeAll(where: { $0.id == current.id })
                merged.removeAll(where: { $0.id == next.id })

                let end: Date?
                if let currentEnd = current.end, let nextEnd = next.end {
                    end = Swift.max(currentEnd, nextEnd)
                } else {
                    end = nil
                }
                merged.append(TimeEntry(start: current.start, end: end))
            } else {
                index += 1
            }
        }

        return merged
    }

    func getBreak(between index1: Int, and index2: Int) -> Int? {
        guard index1 >= 0,
              index1 < self.count,
              index2 >= 0,
              index2 < self.count else { return nil }
        return [self[index1], self[index2]].totalBreaksInSeconds
    }
}
