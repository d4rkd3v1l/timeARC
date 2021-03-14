//
//  AbsenceType.swift
//  timeARC
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
        AbsenceType(id: UUID(uuidString: "13371337-1337-1337-1337-133713371337")!, title: "Dummy", icon: "😈", offPercentage: 0.42)
    }

    static var reservedUUIDs: [UUID] {
        [
            UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
            UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
            UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
            UUID(uuidString: "00000000-0000-0000-0000-000000000007")!,
            UUID(uuidString: "00000000-0000-0000-0000-000000000008")!
        ]
    }
}

extension AbsenceType: SingleValueSelectable {
    var localizedTitle: String {
        "\(self.icon) \(NSLocalizedString(self.title, comment: ""))"
    }
}
