//
//  StatisticsOvertimeView.swift
//  timeARC
//
//  Created by d4Rk on 12.02.21.
//

import SwiftUI
import SwiftUICharts

struct StatisticsOvertimeView: View {
    let startDate: Date
    let endDate: Date
    let timeEntries: [Day: [TimeEntry]]
    let absenceEntries: [AbsenceEntry]
    let relevantDays: [Day]
    let workingDuration: Int

    var body: some View {
        let average = self.timeEntries.averageOvertimeDuration(workingDuration: self.workingDuration)
        let total = self.timeEntries.totalOvertimeDuration(workingDays: self.relevantDays, workingDuration: self.workingDuration, absenceEntries: self.absenceEntries)

        VStack {
            StatisticsSectionHeaderView(imageName: "hourglass.badge.plus",
                                        title: "overtime")

            BarChartView(dataPoints: self.timeEntries.dataPoints(from: self.startDate,
                                                                 to: self.endDate,
                                                                 for: { $0.totalOvertimeDuration(workingDays: [],
                                                                                                 workingDuration: self.workingDuration,
                                                                                                 absenceEntries: self.absenceEntries) }),
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
                                        description: "You've worked overtime for an average of \(average.formattedFull() ?? "0h") a day with a total of \(total.formattedFull() ?? "0h").")
        }
        .padding(.vertical, 5)
    }
}
