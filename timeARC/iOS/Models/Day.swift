//
//  Day.swift
//  timeARC
//
//  Created by d4Rk on 10.10.20.
//

import SwiftUI

/// Date wrapper when only accuracy of days is needed, but still keep things like Equatable (on a day basis).
struct Day: Identifiable, Equatable, Hashable, Comparable, Codable {
    var date: Date

    var id: Date {
        self.date
    }

    var description: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter.string(from: self.date)
    }

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
