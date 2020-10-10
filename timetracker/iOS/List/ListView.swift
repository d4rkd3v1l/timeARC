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
        let timeEntries: [Date: [TimeEntry]]
        let buttonTextColor: Color
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(timeEntries: state.timeState.timeEntries,
                     buttonTextColor: state.settingsState.accentColor.contrastColor(for: self.colorScheme))
    }

    @StateObject private var expansionHandler = ExpansionHandler<Date>()

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
                            DayView(date: day,
                                    timeEntries: timeEntries,
                                    buttonTextColor: props.buttonTextColor,
                                    isExpanded: self.expansionHandler.isExpanded(day))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation { self.expansionHandler.toggleExpanded(for: day) }
                                }
                        }
                    }
                }
                Button(action: {
                    self.partialSheetManager.showPartialSheet() {
                        let timeEntry = TimeEntry(start: Date(), end: Date())
                        TimeEntryEditView(timeEntry: timeEntry,
                                          title: "addEntryTitle",
                                          buttonTitle: "add",
                                          buttonTextColor: props.buttonTextColor) {
                            store.dispatch(action: AddTimeEntry(timeEntry: $0))
                        }
                    }
                }) {
                    Text("addEntry")
                        .frame(width: 200, height: 50)
                        .font(Font.body.bold())
                        .foregroundColor(props.buttonTextColor)
                        .background(Color.accentColor)
                        .cornerRadius(25)
                }
                .padding(.vertical, 10)
            }
            .navigationBarTitle("list")
        }
    }

    struct DayView: View {
        let date: Date
        let timeEntries: [TimeEntry]
        let buttonTextColor: Color

        @EnvironmentObject var partialSheetManager: PartialSheetManager
        @ObservedObject var updater = ViewUpdater(updateInterval: 60)
        @Binding var isExpanded: Bool

        var body: some View {
            DisclosureGroup(
                isExpanded: self.$isExpanded,
                content: {
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
                                                      title: "updateEntryTitle",
                                                      buttonTitle: "update",
                                                      buttonTextColor: self.buttonTextColor) {
                                        store.dispatch(action: UpdateTimeEntry(timeEntry: $0))
                                    }
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
                        Text(self.date.startOfDay.formatted("EE, dd.MM.YYYY"))
                        Spacer()
                        ZStack {
                            Text("00:00").hidden()
                            Text(self.timeEntries.totalDurationInSeconds.formatted(allowedUnits: [.hour, .minute]) ?? "")
                        }
                    }
                })
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

