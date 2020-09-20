//
//  EntryDetails.swift
//  timetracker
//
//  Created by d4Rk on 21.07.20.
//

import SwiftUI
import SwiftUIFlux

struct EntryDetailsView: ConnectedView {
    struct Props {
        let timeEntries: [TimeEntry]
        let workingMinutesPerDay: Int
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        let timeEntries = state.timeState.timeEntries
            .filter { $0.isRelevant(for: self.selectedDate) }
            .sorted(by: { $0.start < $1.start })

        return Props(timeEntries: timeEntries,
                     workingMinutesPerDay: state.settingsState.workingMinutesPerDay
        )
    }

    @State private var editTimeEntry: TimeEntry?

    @State var selectedDate: Date
    @State var duration: Int = 0
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    func body(props: Props) -> some View {
        ZStack {
            VStack {
                Spacer(minLength: 30)
                ArcViewFull(duration: self.duration, maxDuration: props.workingMinutesPerDay * 60)
                    .frame(width: 200, height: 200)
                    .onReceive(self.timer) { _ in
                        self.duration = props.timeEntries.totalDurationInSeconds(on: self.selectedDate)
                    }
                Spacer(minLength: 30)
                Form {
                    ForEach(props.timeEntries, id: \.self) { timeEntry in
                        TimeEntryListView(timeEntry: timeEntry)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.editTimeEntry = timeEntry
                            }
                    }
                    .onDelete(perform: { indexSet in
                        indexSet.forEach { index in
                            let timeEntry = props.timeEntries[index]
                            store.dispatch(action: DeleteTimeEntry(id: timeEntry.id))
                        }
                    })
                }
                Button(action: {
                    store.dispatch(action: AddTimeEntry(start: self.selectedDate, end: self.selectedDate))
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
            .navigationTitle(self.selectedDate.formatted("MMM d, yyyy"))

            if let timeEntry = self.editTimeEntry {
                TimeEntryEditViewPresenter(timeEntry: timeEntry)
                    .onTapGesture {
                        self.editTimeEntry = nil
                    }
            }
        }
    }
}

// MARK: - Preview

struct EntryDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        store.dispatch(action: InitFlux())
        store.dispatch(action: ToggleTimer())
        return StoreProvider(store: store) {
            EntryDetailsView(selectedDate: Date())
                .accentColor(.green)
        }
    }
}
