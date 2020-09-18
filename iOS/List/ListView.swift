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

    @State private var expandedId: UUID?
    func isExpanded(id: UUID) -> Binding<Bool> {
        return Binding(
            get: { id == self.expandedId },
            set: { self.expandedId = $0 == true ? id : nil }
        )
    }
    func toggleExpanded(for id: UUID) {
        self.expandedId = self.expandedId == id ? nil : id
    }

    func body(props: Props) -> some View {
        NavigationView {
            Form {
                ForEach(props.timeEntries.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                    Section(header: Text(key.formatted("MMMM dd yyyy"))) {
                        ForEach(value.sorted(by: { $0.start < $1.start }), id: \.self) { timeEntry in
                            TimeEntryPicker(timeEntry: timeEntry, isExpanded: self.isExpanded(id: timeEntry.id))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation { self.toggleExpanded(for: timeEntry.id) }
                                }

                        }
//                        .onDelete(perform: { indexSet in
//                            indexSet.forEach { index in
//                                let timeEntry = props.timeEntries[index]
//                                store.dispatch(action: DeleteTimeEntry(id: timeEntry.id))
//                            }
//                        })
                    }
                }
            }
            .navigationBarTitle("list")
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
        }
    }
}
