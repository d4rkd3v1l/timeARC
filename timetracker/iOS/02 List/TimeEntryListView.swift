//
//  ListDayView.swift
//  timetracker
//
//  Created by d4Rk on 10.10.20.
//

import SwiftUI

struct TimeEntryListView: View {
    let day: Day
    let timeEntries: [TimeEntry]
    let absenceEntries: [AbsenceEntry]

    @ObservedObject var updater = ViewUpdater(updateInterval: 60)

    var body: some View {
        HStack {
            ZStack(alignment: .leading) {
                Text("0000").hidden()
                Text(self.day.date.formatted("EE"))
            }
            Text(self.day.date.formatted("dd.MM.YYYY"))
            Spacer()
            ForEach(self.absenceEntries, id: \.self) { entry in
                Text(entry.type.icon)
            }
            Spacer()
            ZStack {
                Text("00:00").hidden()
                Text(self.timeEntries.totalDurationInSeconds.formatted(allowedUnits: [.hour, .minute]) ?? "")
            }
        }
    }
}
