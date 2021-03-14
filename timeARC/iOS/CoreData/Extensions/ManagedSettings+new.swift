//
//  ManagedSettings+new.swift
//  timeARC
//
//  Created by d4Rk on 05.03.21.
//

import CoreData

extension ManagedSettings {
    static func createInitialSettings(with context: NSManagedObjectContext) throws -> ManagedSettings {
        let managedSettings = ManagedSettings(context: context)

        managedSettings.accentColor = CodableColor.green.rawValue
        managedSettings.timerDisplayMode = TimerDisplayMode.countUp.rawValue
        managedSettings.workingDuration = 28800

        let workingWeekDays: [WeekDay] = [.monday,
                                          .tuesday,
                                          .wednesday,
                                          .thursday,
                                          .friday]
        managedSettings.workingWeekDays = workingWeekDays.map { $0.rawValue }

        try context.save()

        return managedSettings
    }
}
