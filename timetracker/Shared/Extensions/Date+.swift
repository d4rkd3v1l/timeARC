//
//  Date+.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import Foundation

extension Date {
    func durationFormatted(until otherDate: Date, allowedUnits: NSCalendar.Unit = [.hour, .minute]) -> String? {
        let components = Calendar.current.dateComponents([.hour, .minute, .second],
                                                       from: self,
                                                       to: otherDate)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = allowedUnits
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: components)
    }

    func isInSameDay(as date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }

    func byAdding(_ dateComponents: DateComponents) -> Date {
        return Calendar.current.date(byAdding: dateComponents, to: self) ?? self
    }

    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: self.startOfDay)!
    }

    var firstOfYear: Date {
        let current = Calendar.current.dateComponents([.year], from: self)
        return Calendar.current.date(from: DateComponents(year: current.year, month: 1, day: 1)) ?? self
    }

    var lastOfYear: Date {
        return Calendar.current.date(byAdding: DateComponents(year: 1, day: -1), to: self.firstOfYear) ?? self
    }

    var firstOfMonth: Date {
        let current = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: DateComponents(year: current.year, month: current.month, day: 1)) ?? self
    }

    var lastOfMonth: Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.firstOfMonth) ?? self
    }

    var firstOfWeek: Date {
        let current = Calendar.current.dateComponents([.year, .weekOfYear], from: self)
        return Calendar.current.date(from: DateComponents(weekOfYear: current.weekOfYear, yearForWeekOfYear: current.year)) ?? self
    }

    var lastOfWeek: Date {
        return Calendar.current.date(byAdding: DateComponents(day: -1, weekOfYear: 1), to: self.firstOfWeek) ?? self
    }

    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    var hours: Int {
        return Calendar.current.component(.hour, from: self)
    }

    var minutes: Int {
        return Calendar.current.component(.minute, from: self)
    }

    var hoursAndMinutesInMinutes: Int {
        return (self.hours * 60) + self.minutes
    }

    /// Keeps the current date, but adopts the time from `time`.
    func withTime(from time: Date) -> Date? {
        return combineDateWithTime(date: self, time: time)
    }

    /// Keeps the current time, but adopts the date from `date`.
    func withDate(from date: Date) -> Date? {
        return combineDateWithTime(date: date, time: self)
    }
}

private func combineDateWithTime(date: Date, time: Date) -> Date? {
    let calendar = NSCalendar.current

    let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
    let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)

    var mergedComponents = DateComponents()
    mergedComponents.year = dateComponents.year
    mergedComponents.month = dateComponents.month
    mergedComponents.day = dateComponents.day
    mergedComponents.hour = timeComponents.hour
    mergedComponents.minute = timeComponents.minute
    mergedComponents.second = timeComponents.second

    return calendar.date(from: mergedComponents)
}

extension Array where Element == Date {
    var averageTime: Date {
        let averageTimerInterval = self
            .map { $0.timeIntervalSince($0.startOfDay) }
            .average()

        return Date(timeInterval: averageTimerInterval, since: Date().startOfDay)
    }
}

extension Int {
    var hoursAndMinutes: Date {
        return Date().startOfDay.addingTimeInterval(Double(self*60))
    }
}

extension NSCalendar.Unit {
    var dateFormat: String {
        switch self {
        case .hour:     return "HH"
        case .minute:   return "mm"
        case .second:   return "ss"
        default:        return "Not implemented"
        }
    }
}