//
//  WeekDay.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 14.08.20.
//

import SwiftUI

enum WeekDay: Int, Identifiable, Comparable, CaseIterable, Codable {
    var id: WeekDay { self }

    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    init(_ appleWeekDay: Int) {
        switch appleWeekDay {
        case 1...7:
            self.init(rawValue: appleWeekDay)!
        default:
            self = .monday
        }
    }

    /// Sort index by considering the first day of the week of the current calendar.
    var sortIndex: Int {
        let index = self.rawValue - Calendar.current.firstWeekday + 7
        return (index % 7)
    }

    static func < (lhs: WeekDay, rhs: WeekDay) -> Bool {
        lhs.sortIndex < rhs.sortIndex
    }

    var symbol: String {
        return Calendar.current.weekdaySymbols[self.rawValue - 1]
    }

    var shortSymbol: String {
        return Calendar.current.shortWeekdaySymbols[self.rawValue - 1]
    }
}

extension WeekDay: MultipleValuesSelectable {
    static var availableItems: [WeekDay] {
        return self.allCases.sorted()
    }

    var title: String {
        return self.symbol
    }
}

extension Array where Element == WeekDay {
    func workingDays(startDate: Date,
                     endDate: Date) -> [Day] {
        let workingDays = stride(from: startDate.startOfDay,
                                 through: endDate.endOfDay,
                                 by: 86400)
            .filter {
                let weekday = Calendar.current.component(.weekday, from: $0)
                return self.contains(WeekDay(weekday))
            }
            .map { $0.day }

        return workingDays
    }
}
