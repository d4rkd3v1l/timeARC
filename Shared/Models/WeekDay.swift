//
//  WeekDay.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 14.08.20.
//

enum WeekDay: Int, CaseIterable, Codable {
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
}
