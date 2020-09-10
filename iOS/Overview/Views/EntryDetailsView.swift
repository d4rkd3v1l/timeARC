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

    @State var selectedDate: Date
    @State var duration: Int = 0
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    var arcViewSize: CGFloat {
        return self.expandedId == nil ? 200 : 100
    }

    func body(props: Props) -> some View {
        VStack {
            Spacer(minLength: 30)
            ArcViewFull(duration: self.duration, maxDuration: props.workingMinutesPerDay * 60)
                .frame(width: self.arcViewSize, height: self.arcViewSize)
                .onReceive(self.timer) { _ in
                    self.duration = props.timeEntries.totalDurationInSeconds(on: self.selectedDate)
                }
            Spacer(minLength: 30)
            Form {
                ForEach(props.timeEntries, id: \.self) { timeEntry in
                    Bla(timeEntry: timeEntry, isExpanded: self.isExpanded(id: timeEntry.id))
                        .onTapGesture {
                            withAnimation { self.toggleExpanded(for: timeEntry.id) }
                        }

//                    HStack {
//                        TimeEntryPicker(initialDate: timeEntry.start,
//                                        rangeThrough: ...timeEntry.actualEnd) { start in
//                            store.dispatch(action: UpdateTimeEntry(id: timeEntry.id,
//                                                                   start: start,
//                                                                   end: timeEntry.end))
//                        }
//                        Image(systemName: "arrow.right")
//                        TimeEntryPicker(initialDate: timeEntry.actualEnd,
//                                        rangeFrom: timeEntry.start...) { end in
//                            store.dispatch(action: UpdateTimeEntry(id: timeEntry.id,
//                                                                   start: timeEntry.start,
//                                                                   end: end))
//                        }
//                        Image(systemName: "clock")
//                        Text(timeEntry.durationFormatted() ?? "")
//                    }
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

struct Bla: View {
    let timeEntry: TimeEntry
    @Binding var isExpanded: Bool

    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date() // TODO: Fix this, nil is not supported, so use a "magic date" instead?

    var body: some View {
        DisclosureGroup(
            isExpanded: self.$isExpanded,
            content: {
                HStack {
                    DatePicker("", selection: self.$startDate, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .onChange(of: self.startDate) { start in
                            store.dispatch(action: UpdateTimeEntry(id: self.timeEntry.id, start: start, end: self.timeEntry.end))
                        }
                        .environment(\.locale, Locale(identifier: "de"))
                        .onAppear { self.startDate = self.timeEntry.start }
                        .frame(width: 120, height: 200, alignment: .center)
                        .clipped()
                    Spacer()
                    Image(systemName: "arrow.right")
                    Spacer()
                    DatePicker("", selection: self.$endDate, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .onChange(of: self.endDate) { end in
                            store.dispatch(action: UpdateTimeEntry(id: self.timeEntry.id, start: self.timeEntry.start, end: end))
                        }
                        .environment(\.locale, Locale(identifier: "de"))
                        .onAppear { self.endDate = self.timeEntry.end ?? Date() }
                        .frame(width: 120, height: 200, alignment: .center)
                        .clipped()
                }
            },
            label: {
                HStack {
                    Text("\(timeEntry.start.formatted("HH:mm"))")
                    Spacer()
                    Image(systemName: "arrow.right")
                    Spacer()
                    Text("\(timeEntry.end?.formatted("HH:mm") ?? "now")")
                    Spacer()
                    Image(systemName: "clock")
                    Text("\(timeEntry.durationFormatted(allowedUnits: [.hour, .minute]) ?? "")")
                }
            }
        )
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

// TODO: Find a better name^^
struct DisclosureGroupExpansionManager<T: Equatable> {
    @State private var expandedId: T?

    func isExpanded(id: T) -> Binding<Bool> {
        return Binding(
            get: { id == self.expandedId },
            set: { self.expandedId = $0 == true ? id : nil }
        )
    }

    func toggleExpanded(for id: T) {
        self.expandedId = self.expandedId == id ? nil : id
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
