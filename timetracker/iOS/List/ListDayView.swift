//
//  ListDayView.swift
//  timetracker
//
//  Created by d4Rk on 10.10.20.
//

import SwiftUI
import PartialSheet

struct DayView: View {
    let day: Day
    let timeEntries: [TimeEntry]
    let absenceEntries: [AbsenceEntry]
    let absenceTypes: [AbsenceType]

    @EnvironmentObject var partialSheetManager: PartialSheetManager
    @ObservedObject var updater = ViewUpdater(updateInterval: 60)
    @Binding var isExpanded: Bool

    var body: some View {
        DisclosureGroup(
            isExpanded: self.$isExpanded,
            content: {
                ForEach(self.absenceEntries, id: \.self) { absenceEntry in
                    AbsenceEntryListView(absenceEntry: absenceEntry)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.partialSheetManager.showPartialSheet() {
                                AbsenceEntryEditView(absenceEntry: absenceEntry,
                                                     absenceTypes: self.absenceTypes,
                                                     title: "updateAbsenceEntryTitle",
                                                     buttonTitle: "update",
                                                     onUpdate: {
                                                        store.dispatch(action: UpdateAbsenceEntry(absenceEntry: $0))
                                                     },
                                                     onDelete: {
                                                        store.dispatch(action: DeleteAbsenceEntry(absenceEntry: absenceEntry, onlyForDay: nil))
                                                     })
                            }
                        }
                }
                .onDelete(perform: { indexSet in
                    indexSet.forEach { index in
                        let absenceEntry = self.absenceEntries[index]
                        store.dispatch(action: DeleteAbsenceEntry(absenceEntry: absenceEntry, onlyForDay: self.day))
                    }
                })
                // TODO: Check why only "lastModified", everything else seems to lead to following error.
                //
                // Fatal error: Duplicate keys of type 'TimeEntry' were found in a Dictionary.
                // This usually means either that the type violates Hashable's requirements, or
                // that members of such a dictionary were mutated after insertion.
                ForEach(self.timeEntries, id: \.self.lastModified) { timeEntry in
                    TimeEntryListView(timeEntry: timeEntry)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.partialSheetManager.showPartialSheet() {
                                TimeEntryEditView(timeEntry: timeEntry,
                                                  title: "updateTimeEntryTitle",
                                                  buttonTitle: "update",
                                                  onUpdate: {
                                                    store.dispatch(action: UpdateTimeEntry(timeEntry: $0))
                                                  },
                                                  onDelete: {
                                                    store.dispatch(action: DeleteTimeEntry(timeEntry: timeEntry))
                                                  })
                            }
                        }
                }
                .onDelete(perform: { indexSet in
                    indexSet.forEach { index in
                        let timeEntry = self.timeEntries[index]
                        store.dispatch(action: DeleteTimeEntry(timeEntry: timeEntry))
                    }
                })
            },
            label: {
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
            })
    }
}
