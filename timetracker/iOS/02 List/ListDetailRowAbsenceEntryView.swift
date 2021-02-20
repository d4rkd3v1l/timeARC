//
//  ListDetailRowAbsenceEntryView.swift
//  timeARC
//
//  Created by d4Rk on 19.02.21.
//

import SwiftUI

struct ListDetailRowAbsenceEntryView: View {
    let absenceEntry: AbsenceEntry
    let workingDays: [Day]

    func format(value: Float) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2

        let number = NSNumber(value: value)
        return formatter.string(from: number)
    }

    var body: some View {
        VStack {
            NavigationLink(destination: ListAbsenceEntryUpdateView(absenceEntry: self.absenceEntry)) {
                HStack {
                    Text(self.absenceEntry.type.localizedTitle)
                    Spacer()

                    let length = [self.absenceEntry].totalDurationInDays(for: self.workingDays)
                    if length != 1 {
                        HStack(spacing: 0) {
                            Text("\(self.format(value: length) ?? "") ")
                            Text("days")
                        }
                    }
                }
            }
        }
    }
}
