//
//  TimeEntry+DataPoints.swift
//  timeARC
//
//  Created by d4Rk on 12.02.21.
//

import SwiftUI
import SwiftUICharts

extension Dictionary where Key == Day, Value == [TimeEntry] {
    func dataPoints(from startDate: Date, to endDate: Date, for property: ([Day: [TimeEntry]]) -> Int) -> [DataPoint] {
        let legend = Legend(color: Color.accentColor, label: "Legend")
        let range = stride(from: startDate,
                           through: endDate,
                           by: 86400)

        let dataPoints: [DataPoint] = range.map { date in
            let timeEntries = self[date.day] ?? []
            return DataPoint(value: Double(property([date.day: timeEntries])) / 3600, label: "DataPoint", legend: legend)
        }

        return dataPoints
    }
}
