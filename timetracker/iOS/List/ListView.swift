//
//  ListView.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 18.09.20.
//

import SwiftUI
import SwiftUIFlux
import PartialSheet

struct ListView: ConnectedView {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var partialSheetManager: PartialSheetManager

    struct Props {
        let timeEntries: [Day: [TimeEntry]]
        let absenceEntries: [AbsenceEntry]
        let absenceTypes: [AbsenceType]
        let buttonTextColor: Color
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(timeEntries: state.timeState.timeEntries,
                     absenceEntries: state.timeState.absenceEntries,
                     absenceTypes: state.settingsState.absenceTypes,
                     buttonTextColor: state.settingsState.accentColor.contrastColor(for: self.colorScheme))
    }

    @StateObject private var expansionHandler = ExpansionHandler<Day>()

    func body(props: Props) -> some View {
        NavigationView {
            VStack {
                if props.timeEntries.isEmpty {
                    Text("noEntriesYet")
                        .padding(.all, 50)
                        .multilineTextAlignment(.center)
                    Spacer()
                } else {
                    Form {
                        ForEach(props.timeEntries.sorted(by: { $0.key > $1.key }), id: \.key) { day, timeEntries in
                            DayView(day: day,
                                    timeEntries: timeEntries,
                                    absenceEntries: props.absenceEntries.absenceEntriesFor(day: day),
                                    absenceTypes: props.absenceTypes,
                                    buttonTextColor: props.buttonTextColor,
                                    isExpanded: self.expansionHandler.isExpanded(day))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation { self.expansionHandler.toggleExpanded(for: day) }
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
                            self.partialSheetManager.showPartialSheet() {
                                let timeEntry = TimeEntry(start: Date(), end: Date())
                                TimeEntryEditView(timeEntry: timeEntry,
                                                  title: "addTimeEntryTitle",
                                                  buttonTitle: "add",
                                                  buttonTextColor: props.buttonTextColor) {
                                    store.dispatch(action: AddTimeEntry(timeEntry: $0))
                                }
                            }
                        }) {
                            Label("addTimeEntry", systemImage: "tray.and.arrow.down.fill")
                        }

                        Button(action: {
                            guard let initialAbsenceType = props.absenceTypes.first else { return }
                            self.partialSheetManager.showPartialSheet() {
                                let absenceEntry = AbsenceEntry(type: initialAbsenceType, start: Day(), end: Day())
                                AbsenceEntryEditView(absenceEntry: absenceEntry,
                                                     absenceTypes: props.absenceTypes,
                                                     title: "addAbsenceEntryTitle",
                                                     buttonTitle: "add",
                                                     buttonTextColor: props.buttonTextColor) {
                                    store.dispatch(action: AddAbsenceEntry(absenceEntry: $0))
                                }
                            }
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
        store.dispatch(action: InitFlux())

        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        store.dispatch(action: AddTimeEntry(timeEntry: TimeEntry(start: formatter.date(from: "01.01.2020 08:27")!, end: formatter.date(from: "01.01.2020 12:13")!)))
        store.dispatch(action: AddTimeEntry(timeEntry: TimeEntry(start: formatter.date(from: "01.01.2020 12:54")!, end: formatter.date(from: "01.01.2020 18:30")!)))
        store.dispatch(action: AddTimeEntry(timeEntry: TimeEntry(start: formatter.date(from: "04.01.2020 08:27")!, end: formatter.date(from: "04.01.2020 12:13")!)))

        return StoreProvider(store: store) {
            ListView()
                .accentColor(.green)
                .environment(\.colorScheme, .dark)
        }
    }
}

