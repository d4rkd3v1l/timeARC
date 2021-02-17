//
//  ListView.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 18.09.20.
//

import SwiftUI
import SwiftUIFlux

struct ListView: ConnectedView {
    struct Props {
        let timeEntries: [Day: [TimeEntry]]
        let absenceEntries: [AbsenceEntry]
        let absenceTypes: [AbsenceType]
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(timeEntries: state.timeState.timeEntries,
                     absenceEntries: state.timeState.absenceEntries,
                     absenceTypes: state.settingsState.absenceTypes)
    }

    func body(props: Props) -> some View {

        NavigationView {
            VStack {
                if props.timeEntries.isEmpty {
                    Text("noEntriesYet")
                        .padding(.all, 50)
                        .multilineTextAlignment(.center)
                    Spacer()
                } else {
                    List {
                        ForEach(props.timeEntries.sorted(by: { $0.key > $1.key }), id: \.key) { day, timeEntries in
                            NavigationLink(destination: TimeEntryDetailView(day: day)) {
                                TimeEntryListView(day: day,
                                                  timeEntries: timeEntries,
                                                  absenceEntries: props.absenceEntries.absenceEntries(for: day))
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("list")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: {
//                            self.partialSheetManager.showPartialSheet() {
//                                let timeEntry = TimeEntry(start: Date(), end: Date())
//                                TimeEntryEditView(timeEntry: timeEntry,
//                                                  title: "addTimeEntryTitle",
//                                                  buttonTitle: "add") {
//                                    store.dispatch(action: AddTimeEntry(timeEntry: $0))
//                                }
//                            }
                        }) {
                            Label("addTimeEntry", systemImage: "tray.and.arrow.down.fill")
                        }

                        Button(action: {
//                            guard let initialAbsenceType = props.absenceTypes.first else { return }
//                            self.partialSheetManager.showPartialSheet() {
//                                let absenceEntry = AbsenceEntry(type: initialAbsenceType, start: Day(), end: Day())
//                                AbsenceEntryEditView(absenceEntry: absenceEntry,
//                                                     absenceTypes: props.absenceTypes,
//                                                     title: "addAbsenceEntryTitle",
//                                                     buttonTitle: "add") {
//                                    store.dispatch(action: AddAbsenceEntry(absenceEntry: $0))
//                                }
//                            }
                        }) {
                            Label("addAbsenceEntry", systemImage: "calendar")
                        }
                    }
                    label: {
                        Text("add")
                            .padding([.top, .bottom, .leading])
                    }
                }
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
            .accentColor(.green)
            .environment(\.colorScheme, .dark)
    }
}
