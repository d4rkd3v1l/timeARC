//
//  Day.swift
//  timetracker
//
//  Created by d4Rk on 10.10.20.
//

import SwiftUI

/// Date wrapper when only accuracy of days is needed, but still keep things like Equatable (on a day basis).
struct Day: Equatable, Hashable, Comparable, Codable {
    let date: Date

    init(_ date: Date) {
        self.date = date.startOfDay
    }

    init() {
        self.date = Date().startOfDay
    }

    func addingDays(_ days: Int) -> Day {
        return self.date.byAdding(DateComponents(day: days)).day
    }

    static func < (lhs: Day, rhs: Day) -> Bool {
        lhs.date < rhs.date
    }
}

extension Date {
    var day: Day {
        return Day(self)
    }
}
