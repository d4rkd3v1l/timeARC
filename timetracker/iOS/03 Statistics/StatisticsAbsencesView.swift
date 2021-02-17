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
    
    @StateObject private var expansionHandler = ExpansionHandler<ExpandableSection>()
    
    var body: some View {
        VStack {
            StatisticsSectionHeaderView(imageName: "car.fill",
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
            
            DisclosureGroup(
                isExpanded: self.expansionHandler.isExpanded(.absenceDays),
                content: {
                    ForEach(self.absenceEntries.totalDurationInDaysByType().sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                        
                        HStack {
                            Text(key.localizedTitle)
                            Spacer()
                            Text(self.formattedAbsence(for: value))
                        }
                    }
                },
                label: {
                    HStack {
                        Text("absenceDays")
                        Spacer()
                        Text(self.formattedAbsence(for: self.absenceEntries.totalDurationInDays()))
                    }
                }
            )
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation { self.expansionHandler.toggleExpanded(for: .absenceDays) }
            }
            .disabled(self.absenceEntries.isEmpty)
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
