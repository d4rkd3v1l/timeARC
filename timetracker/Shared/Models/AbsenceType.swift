//
//  AbsenceType.swift
//  timetracker
//
//  Created by d4Rk on 10.10.20.
//

import SwiftUI

struct AbsenceType: Identifiable, Equatable, Hashable, Codable {
    let id: UUID
    var title: String
    var icon: String
    var offPercentage: Float

    static var dummy: AbsenceType {
        return AbsenceType(id: UUID(), title: "Dummy", icon: "😈", offPercentage: 42)
    }
}

extension AbsenceType: SingleValueSelectable {
    var localizedTitle: String {
        return "\(NSLocalizedString(self.title, comment: "")) \(self.icon)"
    }
}
