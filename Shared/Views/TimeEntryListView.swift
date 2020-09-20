//
//  TimeEntryListView.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 20.09.20.
//

import SwiftUI

struct TimeEntryListView: View {
    let timeEntry: TimeEntry

    var body: some View {
        HStack {
            Text("\(timeEntry.start.formatted("HH:mm"))")
            Spacer()
            Image(systemName: "arrow.right")
            Spacer()
            Text("\(timeEntry.end?.formatted("HH:mm") ?? "now")")
            Spacer()
            Image(systemName: "clock")
            Text("\(timeEntry.durationFormatted(allowedUnits: [.hour, .minute]) ?? "")")
        }
    }
}
