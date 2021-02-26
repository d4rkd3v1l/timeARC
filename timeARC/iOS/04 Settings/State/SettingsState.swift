//
//  SettingsState.swift
//  timeARC
//
//  Created by d4Rk on 14.08.20.
//

import SwiftUI
import SwiftUIFlux

struct SettingsState: FluxState, Codable {
    var workingWeekDays: [WeekDay] = [.monday,
                                      .tuesday,
                                      .wednesday,
                                      .thursday,
                                      .friday]
    var workingDuration: Int = 28800
    var accentColor: CodableColor = .green
    var absenceTypes: [AbsenceType] = [AbsenceType(id: UUID(), title: "bankHoliday", icon: "🙌", offPercentage: 1),
                                       AbsenceType(id: UUID(), title: "holiday", icon: "🏝", offPercentage: 1),
                                       AbsenceType(id: UUID(), title: "holidayHalfADay", icon: "🏝½", offPercentage: 0.5),
                                       AbsenceType(id: UUID(), title: "sick", icon: "🤒", offPercentage: 1),
                                       AbsenceType(id: UUID(), title: "childSick", icon: "🤒🧒", offPercentage: 1),
                                       AbsenceType(id: UUID(), title: "vocationalSchool", icon: "🏫", offPercentage: 1),
                                       AbsenceType(id: UUID(), title: "parentalLeave", icon: "👨‍🍼", offPercentage: 1),
                                       AbsenceType(id: UUID(), title: "training", icon: "📚", offPercentage: 1)]
}
