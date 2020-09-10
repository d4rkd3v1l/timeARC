//
//  TimeEntry.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import Foundation

struct TimeEntry: Identifiable, Equatable, Hashable, Codable {
    private (set) var id = UUID()
    var start: Date
    var end: Date?

    init(start: Date = Date(timeIntervalSinceNow: 0), end: Date? = nil) {
        self.start = start
        self.end = end
    }

    var isRunning: Bool {
        return self.end == nil
    }

    mutating func stop() {
        self.end = Date(timeIntervalSinceNow: 0)
    }

    // MARK: Helper

    var actualEnd: Date {
        return self.end ?? Date(timeIntervalSinceNow: 0)
    }

    func durationFormatted(allowedUnits: NSCalendar.Unit = [.hour, .minute]) -> String? {
        return self.start.durationFormatted(until: self.actualEnd, allowedUnits: allowedUnits)
    }

    func isRelevant(for date: Date) -> Bool {
        return self.start.isInSameDay(as: date)
            || self.actualEnd.isInSameDay(as: date)
            || (self.start < self.actualEnd && (self.start...self.actualEnd).contains(date))
            || (self.actualEnd < self.start && (self.actualEnd...self.start).contains(date))
    }

    func durationInSeconds(on date: Date) -> Int? {
        guard self.isRelevant(for: date) else { return nil }

        let start = self.start.isInSameDay(as: date) ? self.start : date.startOfDay
        let end = self.actualEnd.isInSameDay(as: date) ? self.actualEnd : date.endOfDay

        return Calendar.current
            .dateComponents([.second], from: start, to: end)
            .second
    }

    static func == (lhs: TimeEntry, rhs: TimeEntry) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Extensions

extension Array where Element == TimeEntry {
    func totalDurationInSeconds(on date: Date) -> Int {
        return self
            .compactMap { $0.durationInSeconds(on: date) }
            .reduce(0, +)
    }

    var isTimerRunning: Bool {
        return self.contains(where: { $0.isRunning })
    }
}

extension Int {
    func formatted(allowedUnits: NSCalendar.Unit = [.hour, .minute]) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = allowedUnits
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: DateComponents(second: self))
    }
}
