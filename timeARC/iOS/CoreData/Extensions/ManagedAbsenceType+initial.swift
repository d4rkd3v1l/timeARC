//
//  ManagedAbsenceType+initial.swift
//  timeARC
//
//  Created by d4Rk on 14.03.21.
//

import CoreData

extension ManagedAbsenceType {
    static func createInitialAbsenceTypes(with context: NSManagedObjectContext) throws -> [ManagedAbsenceType] {
        let absenceTypes: [AbsenceType] = [
            AbsenceType(id: AbsenceType.reservedUUIDs[0], title: "bankHoliday", icon: "🙌", offPercentage: 1),
            AbsenceType(id: AbsenceType.reservedUUIDs[1], title: "holiday", icon: "🏝", offPercentage: 1),
            AbsenceType(id: AbsenceType.reservedUUIDs[2], title: "holidayHalfADay", icon: "🏝½", offPercentage: 0.5),
            AbsenceType(id: AbsenceType.reservedUUIDs[3], title: "sick", icon: "🤒", offPercentage: 1),
            AbsenceType(id: AbsenceType.reservedUUIDs[4], title: "childSick", icon: "🤒🧒", offPercentage: 1),
            AbsenceType(id: AbsenceType.reservedUUIDs[5], title: "vocationalSchool", icon: "🏫", offPercentage: 1),
            AbsenceType(id: AbsenceType.reservedUUIDs[6], title: "parentalLeave", icon: "👨‍🍼", offPercentage: 1),
            AbsenceType(id: AbsenceType.reservedUUIDs[7], title: "training", icon: "📚", offPercentage: 1)
        ]

        let managedAbsenceTypes: [ManagedAbsenceType] = absenceTypes.map { absenceType in
            let managedAbsenceType = ManagedAbsenceType(context: context)
            managedAbsenceType.id = absenceType.id
            managedAbsenceType.title = absenceType.title
            managedAbsenceType.icon = absenceType.icon
            managedAbsenceType.offPercentage = absenceType.offPercentage
            return managedAbsenceType
        }

        try context.save()

        return managedAbsenceTypes
    }
}
