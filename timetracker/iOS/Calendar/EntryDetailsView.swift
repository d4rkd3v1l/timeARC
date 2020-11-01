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
        let workingDuration: Int
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        let timeEntries = state.timeState.timeEntries.forDay(self.selectedDay)

        return Props(timeEntries: timeEntries,
                     workingDuration: state.settingsState.workingDuration
        )
    }

    @State private var editTimeEntry: TimeEntry?

    @State var selectedDay: Day
    @State var duration: Int = 0
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    func body(props: Props) -> some View {
        return ZStack {
            VStack {
                Spacer(minLength: 30)
                ArcViewFull(duration: self.duration, maxDuration: props.workingDuration)
                    .frame(width: 200, height: 200)
                    .onReceive(self.timer) { _ in
                        self.duration = props.timeEntries.totalDurationInSeconds
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
                            store.dispatch(action: DeleteTimeEntry(timeEntry: timeEntry))
                        }
                    })
                }
                Button(action: {
                    let timeEntry = TimeEntry(start: self.selectedDay.date, end: self.selectedDay.date)
                    store.dispatch(action: AddTimeEntry(timeEntry: timeEntry))
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
            .navigationTitle(self.selectedDay.date.formatted("MMM d, yyyy"))

//            if let timeEntry = self.editTimeEntry {
//                TimeEntryEditViewPresenter(timeEntry: timeEntry)
//                    .onTapGesture {
//                        self.editTimeEntry = nil
//                    }
//            }
        }
    }
}

// MARK: - Preview

struct EntryDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        store.dispatch(action: InitFlux())
        store.dispatch(action: ToggleTimer())
        return StoreProvider(store: store) {
            EntryDetailsView(selectedDate: Day())
                .accentColor(.green)
        }
    }
}
