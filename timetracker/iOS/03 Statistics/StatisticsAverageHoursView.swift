//
//  StatisticsAverageHoursView.swift
//  timeARC
//
//  Created by d4Rk on 12.02.21.
//

import SwiftUI

struct StatisticsAverageHoursView: View {
    let timeEntries: [Day: [TimeEntry]]
    let workingDays: [Day]

    var body: some View {
        VStack {
            StatisticsSectionHeaderView(imageName: "clock.fill",
                                        title: "averageHours")

            ArcViewAverage(timeEntries: self.timeEntries,
                           workingDays: self.workingDays,
                           color: .accentColor)
                .frame(width: 170, height: 170)

            Text("On average you started your working day at \(self.timeEntries.averageWorkingHoursStartDate().formattedTime()) and finished by \(self.timeEntries.averageWorkingHoursEndDate().formattedTime()).")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 5)
    }
}
