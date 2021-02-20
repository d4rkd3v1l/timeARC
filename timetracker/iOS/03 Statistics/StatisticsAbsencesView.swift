//
//  StatisticsAbsencesView.swift
//  timeARC
//
//  Created by d4Rk on 12.02.21.
//

import SwiftUI

struct StatisticsAbsencesView: View {
    enum ExpandableSection: Equatable {
        case absenceDays
    }
    
    let timeEntries: [Day: [TimeEntry]]
    let absenceEntries: [AbsenceEntry]
    let workingDays: [Day]
    
    var body: some View {
        Group {
            VStack {
                StatisticsSectionHeaderView(imageName: "calendar",
                                            title: "absences")

                HStack {
                    ArcViewFull(duration: self.timeEntries.count,
                                maxDuration: self.workingDays.count,
                                color: .accentColor,
                                allowedUnits: [.second],
                                displayMode: .progress)
                        .frame(width: 150, height: 150)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("daysWorked")
                        Spacer()
                    }
                }
            }

            let absenceDurationInDays = self.absenceEntries.totalDurationInDays(for: self.workingDays)
            if absenceDurationInDays > 0 {
                HStack {
                    Text("totalAbsenceDays")
                    Spacer()
                    Text(self.formattedAbsence(for: absenceDurationInDays))
                }

                ForEach(self.absenceEntries.totalDurationInDaysByType(for: self.workingDays).sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                    HStack {
                        Text(key.localizedTitle)
                        Spacer()
                        Text(self.formattedAbsence(for: value))
                    }
                }
            }
        }
        .padding(.vertical, 5)
    }
    
    private func formattedAbsence(for duration: Float) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: NSNumber(floatLiteral: Double(duration))) ?? ""
    }
}
