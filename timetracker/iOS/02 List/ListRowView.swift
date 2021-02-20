//
//  ListDayView.swift
//  timetracker
//
//  Created by d4Rk on 10.10.20.
//

import SwiftUI

struct ListRowView: View {
    let day: Day
    let timeEntries: [TimeEntry]
    let absenceEntries: [AbsenceEntry]

    @ObservedObject var updater = ViewUpdater(updateInterval: 60)

    var body: some View {
        HStack {
            ZStack(alignment: .leading) {
                Text("XXX").hidden()
                Text(self.day.date.formatted("EE"))
            }

            Text(self.day.date.formatted("MM dd"))

            Spacer()

            ForEach(self.absenceEntries) { entry in
                Text(entry.type.icon)
            }

            Spacer()

            Text(self.timeEntries.totalDurationInSeconds.formatted(allowedUnits: [.hour, .minute]) ?? "")
        }
    }
}
