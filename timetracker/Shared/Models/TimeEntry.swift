//
//  TimeEntry.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import Foundation

struct TimeEntry: Identifiable, Equatable, Hashable, Codable {
    private (set) var id = UUID()
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
    private (set) var lastModified: Date = Date()

    init(start: Date = Date(), end: Date? = nil) {
        self.start = start
        self.end = end
    }

    var isRunning: Bool {
        return self.end == nil
    }

    mutating func stop() {
        self.end = Date()
    }

    // MARK: Helper

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

    static func == (lhs: TimeEntry, rhs: TimeEntry) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Extensions

extension Dictionary where Key == Date, Value == [TimeEntry] {
    func forDay(_ date: Date) -> [TimeEntry] {
        return self[date.startOfDay] ?? []
    }

    func find(_ timeEntry: TimeEntry) -> TimeEntry? {
        // Optimization, works as long as start day did not change
        if let timeEntriesForDay = self[timeEntry.start.startOfDay] {
            return timeEntriesForDay.first(where: { $0.id == timeEntry.id })
        }

        // Fallback, if start day did change (have to go through all the entries in this case)
        return self.values
            .flatMap { $0 }
            .first(where: { $0.id == timeEntry.id })
    }

    /// - Does automatically split `TimeEntry`s into single days, that would otherwise span multiple days
    /// - `TimeEntry`s for each day are sorted ascending by their `start` date
    mutating func insertValidated(_ timeEntry: TimeEntry) {
        timeEntry.splittedIntoSingleDays().forEach { timeEntry in
            let day = timeEntry.start.startOfDay
            if !self.keys.contains(day) {
                self[day] = []
            }

            self[day]?.append(timeEntry)
            self[day] = self[day]?.mergedOverlappingEntries()
        }
    }

    mutating func updateValidated(_ timeEntry: TimeEntry) {
        guard let oldTimeEntry = self.find(timeEntry) else { return }

        var newTimeEntry = oldTimeEntry
        newTimeEntry.start = timeEntry.start
        newTimeEntry.end = timeEntry.end

        self.remove(oldTimeEntry)
        self.insertValidated(newTimeEntry)
    }

    mutating func remove(_ timeEntry: TimeEntry) {
        let day = timeEntry.start.startOfDay
        self[day]?.removeAll(where: { $0.id == timeEntry.id })

        if self[day]?.isEmpty ?? false {
            self.removeValue(forKey: day)
        }
    }
}

extension Array where Element == TimeEntry {
    var totalDurationInSeconds: Int {
        return self
            .compactMap { $0.durationInSeconds }
            .reduce(0, +)
    }

    var totalBreaksInSeconds: Int {
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
                merged.removeAll(where: { $0 == current })
                merged.removeAll(where: { $0 == next })

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
}

extension Int {
    func formatted(allowedUnits: NSCalendar.Unit = [.hour, .minute], zeroFormattingBehavior: DateComponentsFormatter.ZeroFormattingBehavior = .pad) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = allowedUnits
        formatter.zeroFormattingBehavior = zeroFormattingBehavior
        return formatter.string(from: DateComponents(second: self))
    }
}
