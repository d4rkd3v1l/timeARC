//
//  ManagedSettings+new.swift
//  timeARC
//
//  Created by d4Rk on 05.03.21.
//

import CoreData

extension ManagedSettings {
    static func newSettings(with context: NSManagedObjectContext) throws -> ManagedSettings {
        let managedSettings = ManagedSettings(context: context)

        managedSettings.accentColor = CodableColor.green.rawValue
        managedSettings.timerDisplayMode = TimerDisplayMode.countUp.rawValue
        managedSettings.workingDuration = 28800

        let workingWeekDays: [WeekDay] = [.monday,
                                          .tuesday,
                                          .wednesday,
                                          .thursday,
                                          .friday]

        let managedWorkingWeekDays: [ManagedWorkingWeekDay] = workingWeekDays.map { workingWeekDay in
            let managedWorkingWeekDay = ManagedWorkingWeekDay(context: context)
            managedWorkingWeekDay.name = Int64(workingWeekDay.rawValue)
            return managedWorkingWeekDay
        }

        managedSettings.workingWeekDays = Set(managedWorkingWeekDays) as NSSet

        let absenceTypes: [AbsenceType] = [AbsenceType(id: UUID(), title: "bankHoliday", icon: "🙌", offPercentage: 1),
                                           AbsenceType(id: UUID(), title: "holiday", icon: "🏝", offPercentage: 1),
                                           AbsenceType(id: UUID(), title: "holidayHalfADay", icon: "🏝½", offPercentage: 0.5),
                                           AbsenceType(id: UUID(), title: "sick", icon: "🤒", offPercentage: 1),
                                           AbsenceType(id: UUID(), title: "childSick", icon: "🤒🧒", offPercentage: 1),
                                           AbsenceType(id: UUID(), title: "vocationalSchool", icon: "🏫", offPercentage: 1),
                                           AbsenceType(id: UUID(), title: "parentalLeave", icon: "👨‍🍼", offPercentage: 1),
                                           AbsenceType(id: UUID(), title: "training", icon: "📚", offPercentage: 1)]

        let managedAbsenceTypes: [ManagedAbsenceType] = absenceTypes.map { absenceType in
            let managedAbsenceType = ManagedAbsenceType(context: context)
            managedAbsenceType.id = absenceType.id
            managedAbsenceType.title = absenceType.title
            managedAbsenceType.icon = absenceType.icon
            managedAbsenceType.offPercentage = absenceType.offPercentage
            return managedAbsenceType
        }

        managedSettings.absenceTypes = Set(managedAbsenceTypes) as NSSet

        try context.save()

        return managedSettings
    }
}
