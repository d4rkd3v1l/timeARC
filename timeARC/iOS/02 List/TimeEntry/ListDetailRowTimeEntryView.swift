//
//  TimeEntryDetailRowView.swift
//  timeARC
//
//  Created by d4Rk on 19.02.21.
//

import SwiftUI

struct ListDetailRowTimeEntryView: View {
    @Binding var timeEntry: TimeEntry
    @Binding var columnWidths: [Int: CGFloat]

    let breakDurationBefore: Int?
    let breakDurationAfter: Int?

    var body: some View {
        ZStack {
            HStack {
                DatePicker("", selection: self.$timeEntry.start, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .setWidthKey(index: 0)
                    .frame(width: self.columnWidths[0], alignment: .leading)
                    .accessibility(identifier: "ListDetailRowTimeEntry.start")

                Image(systemName: "arrow.right")

                DatePicker("", selection:  self.$timeEntry.end ?? Date(), displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .setWidthKey(index: 1)
                    .frame(width: self.columnWidths[1], alignment: .leading)
                    .accessibility(identifier: "ListDetailRowTimeEntry.end")

                Spacer()

                Text(self.timeEntry.durationFormatted() ?? "")
                    .accessibility(identifier: "ListDetailRowTimeEntry.duration")
            }
            .padding(.vertical, 7)

            HStack {
                Spacer()
                ZStack {
                    if let breakDurationBefore = breakDurationBefore {
                        HStack(spacing: 5) {
                            Text("break")
                            Text(breakDurationBefore.formatted() ?? "")
                                .accessibility(identifier: "ListDetailRowTimeEntry.breakBefore")
                        }
                        .font(.caption2)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .foregroundColor(.primary)
                        .background(Color.tertiarySystemGroupedBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .offset(x: 15, y: -30)
                    }

                    if let breakDurationAfter = breakDurationAfter {
                        HStack(spacing: 5) {
                            Text("break").padding(0)
                            Text(breakDurationAfter.formatted() ?? "")
                                .accessibility(identifier: "ListDetailRowTimeEntry.breakAfter")
                        }
                        .font(.caption2)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .foregroundColor(.primary)
                        .background(Color.tertiarySystemGroupedBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .offset(x: 15, y: 30)
                    }
                }
            }
        }
    }
}
