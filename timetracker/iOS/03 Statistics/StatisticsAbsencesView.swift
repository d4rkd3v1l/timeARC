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
    let relevantDays: [Day]
    
    var body: some View {
        Group {
            let absenceDurationInDays = self.absenceEntries.totalDurationInDays(for: self.relevantDays)

            VStack {
                StatisticsSectionHeaderView(imageName: "calendar",
                                            title: "absences")

                ArcViewFull(duration: self.timeEntries.count,
                            maxDuration: self.relevantDays.count,
                            color: .accentColor,
                            allowedUnits: [.second],
                            displayMode: .progress)
                    .frame(width: 150, height: 150)

                Text("You've worked on \(self.timeEntries.count) of \(self.relevantDays.count) days and tracked absences for \(self.formattedAbsence(for: absenceDurationInDays)) days.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            if absenceDurationInDays > 0 {
                HStack {
                    Text("totalAbsenceDays")
                    Spacer()
                    Text(self.formattedAbsence(for: absenceDurationInDays))
                }

                ForEach(self.absenceEntries.totalDurationInDaysByType(for: self.relevantDays).sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
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
