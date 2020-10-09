//
//  TimeEntryListView.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 20.09.20.
//

import SwiftUI

struct TimeEntryListView: View {
    let timeEntry: TimeEntry

    @ObservedObject var updater = ViewUpdater(updateInterval: 60)

    var body: some View {
        HStack {
            ZStack {
                Text("00:00").hidden()
                Text(timeEntry.start.formatted("HH:mm"))
            }
            Spacer()
            Image(systemName: "arrow.right")
            Spacer()
            ZStack {
                Text("00:00").hidden()
                Text(timeEntry.end?.formatted("HH:mm") ?? "now")
            }
            Spacer()
            ZStack {
                Text("00:00").hidden()
                Text(timeEntry.durationFormatted(allowedUnits: [.hour, .minute]) ?? "")
            }
        }
    }
}
