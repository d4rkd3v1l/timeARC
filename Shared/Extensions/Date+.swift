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

    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: self.startOfDay)!
    }

    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
