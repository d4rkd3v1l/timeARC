//
//  AbsenceType+CoreData.swift
//  timeARC
//
//  Created by d4Rk on 05.03.21.
//

extension AbsenceType {
    init?(_ managedAbsenceType: ManagedAbsenceType) {
        guard let id = managedAbsenceType.id,
              let title = managedAbsenceType.title,
              let icon = managedAbsenceType.icon else { return nil }

        self.init(id: id, title: title, icon: icon, offPercentage: managedAbsenceType.offPercentage)
    }
}
