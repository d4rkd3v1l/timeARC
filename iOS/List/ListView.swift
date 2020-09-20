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
        let timeEntries: [Date: [TimeEntry]]
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(timeEntries: Dictionary(grouping: state.timeState.timeEntries, by: { $0.start.startOfDay }))
    }

    @State private var editTimeEntry: TimeEntry?
    @State private var expandedDay: Date?

    func isExpanded(date: Date) -> Binding<Bool> {
        return Binding(
            get: { date == self.expandedDay },
            set: { self.expandedDay = $0 == true ? date : nil }
        )
    }

    func toggleExpanded(for date: Date) {
        self.expandedDay = self.expandedDay == date ? nil : date
    }

    func body(props: Props) -> some View {
        ZStack {
            NavigationView {
                VStack {
                    Form {
                        ForEach(props.timeEntries.sorted(by: { $0.key > $1.key }), id: \.key) { date, timeEntries in
                            DayView(date: date,
                                    timeEntries: timeEntries.filter { $0.isRelevant(for: date) },
                                    isExpanded: self.isExpanded(date: date),
                                    editTimeEntry: self.$editTimeEntry)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation { self.toggleExpanded(for: date) }
                                }
                        }
                    }
                    Button(action: {
                        store.dispatch(action: AddTimeEntry(start: self.expandedDay ?? Date(), end: self.expandedDay ?? Date()))
                    }) {
                        Text("addEntry")
                            .frame(width: 200, height: 50)
                            .font(Font.body.bold())
                            .foregroundColor(.white)
                            .background(Color.accentColor)
                            .cornerRadius(25)
                    }
                    .padding(.vertical, 10)
                }
                .navigationBarTitle("list")
            }
            if let timeEntry = self.editTimeEntry {
                TimeEntryEditViewPresenter(timeEntry: timeEntry)
                    .onTapGesture {
                        self.editTimeEntry = nil
                    }
            }
        }
    }

    struct DayView: View {
        let date: Date
        let timeEntries: [TimeEntry]

        @Binding var isExpanded: Bool
        @Binding var editTimeEntry: TimeEntry?

        var body: some View {
            DisclosureGroup(
                isExpanded: self.$isExpanded,
                content: {
                    ForEach(timeEntries.sorted(by: { $0.start < $1.start }), id: \.self) { timeEntry in
                        TimeEntryListView(timeEntry: timeEntry)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.editTimeEntry = timeEntry
                            }
                    }
                    .onDelete(perform: { indexSet in
                        indexSet.forEach { index in
                            let timeEntry = self.timeEntries[index]
                            store.dispatch(action: DeleteTimeEntry(id: timeEntry.id))
                        }
                    })
                },
                label: {
                    HStack {
                        Text(date.startOfDay.formatted("EE, dd.MM.YYYY"))
                        Spacer()
                        Image(systemName: "clock")
                        Text(timeEntries.totalDurationInSeconds(on: self.date).formatted(allowedUnits: [.hour, .minute]) ?? "")
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
        store.dispatch(action: AddTimeEntry(start: formatter.date(from: "01.01.2020 08:27")!, end: formatter.date(from: "01.01.2020 12:13")!))
        store.dispatch(action: AddTimeEntry(start: formatter.date(from: "01.01.2020 12:54")!, end: formatter.date(from: "01.01.2020 18:30")!))

        store.dispatch(action: AddTimeEntry(start: formatter.date(from: "04.01.2020 08:27")!, end: formatter.date(from: "04.01.2020 12:13")!))

        return StoreProvider(store: store) {
            ListView()
                .accentColor(.green)
                .environment(\.colorScheme, .dark)
        }
    }
}
