//
//  StatisticsWorkingHoursView.swift
//  timeARC
//
//  Created by d4Rk on 12.02.21.
//

import SwiftUI
import SwiftUICharts

struct StatisticsWorkingHoursView: View {
    let startDate: Date
    let endDate: Date
    let timeEntries: [Day: [TimeEntry]]
    let absenceEntries: [AbsenceEntry]
    let relevantDays: [Day]
    let workingDuration: Int

    var body: some View {
        let average = timeEntries.averageDuration()
        let total = timeEntries.totalDuration()

        VStack {
            StatisticsSectionHeaderView(imageName: "briefcase.fill",
                                        title: "workingHours")

            BarChartView(dataPoints: self.timeEntries.dataPoints(from: self.startDate, to: self.endDate, for: { $0.reduce(0) { $0 + $1.value.totalDurationInSeconds } }),
                         limit: DataPoint(value: Double(average) / 3600,
                                          label: "\(average.formatted() ?? "0:00")",
                                          legend: Legend(color: .gray, label: "")))
                .chartStyle(BarChartStyle(barMinHeight: 100,
                                          showAxis: false,
                                          axisLeadingPadding: 0,
                                          showLabels: false,
                                          labelCount: 0,
                                          showLegends: false))
                .border(width: 2, edges: [.bottom], color: .gray)

            StatisticsSectionFooterView(total: total.formatted() ?? "0:00",
                                        description: "You've worked for an average of \(average.formattedFull() ?? "0h") a day with a total of \(total.formattedFull() ?? "0h").")
        }
        .padding(.vertical, 5)
    }
}
