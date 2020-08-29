//
//  EntryDetails.swift
//  timetracker
//
//  Created by d4Rk on 21.07.20.
//

import SwiftUI
import SwiftUIFlux

class TimeEntriesStorage {
    var timeEntries: [TimeEntry] = []
}

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

    @State var selectedDate: Date
    @State var duration: Int = 0
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    func body(props: Props) -> some View {
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
                    HStack {
                        TimeEntryPicker(initialDate: timeEntry.start,
                                        rangeThrough: ...timeEntry.actualEnd) { start in
                            store.dispatch(action: UpdateTimeEntry(id: timeEntry.id,
                                                                   start: start,
                                                                   end: timeEntry.end))
                        }
                        Image(systemName: "arrow.right")
                        TimeEntryPicker(initialDate: timeEntry.actualEnd,
                                        rangeFrom: timeEntry.start...) { end in
                            store.dispatch(action: UpdateTimeEntry(id: timeEntry.id,
                                                                   start: timeEntry.start,
                                                                   end: end))
                        }
                        Image(systemName: "clock")
                        Text(timeEntry.durationFormatted() ?? "")
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
                Text(LocalizedStringKey("Add Entry"))
                    .frame(width: 200, height: 50)
                    .font(Font.body.bold())
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(25)
            }
            .padding(.vertical, 10)
        }
        .navigationTitle(self.selectedDate.formatted("MMM d, yyyy"))
    }
}

// TODO: "De-hack" this?
struct TimeEntryPicker: View {
    var initialDate = Date()

    @State private var selection: Date = Date()
    var rangeThrough: PartialRangeThrough<Date>?
    var rangeFrom: PartialRangeFrom<Date>?
    var onChange: ((Date) -> Void)?

    var body: some View {
        GeometryReader { geometry in
            if let rangeFrom = self.rangeFrom {
                DatePicker("", selection: self.$selection, in: rangeFrom, displayedComponents: .hourAndMinute)
                    .onChange(of: self.selection) { self.onChange?($0) }

            } else if let rangeThrough = self.rangeThrough {
                DatePicker("", selection: self.$selection, in: rangeThrough, displayedComponents: .hourAndMinute)
                    .onChange(of: self.selection) { self.onChange?($0) }
            }
        }
        .onAppear {
            self.selection = self.initialDate
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
