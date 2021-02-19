//
//  NewListDayView.swift
//  timeARC
//
//  Created by d4Rk on 13.02.21.
//

import SwiftUI
import SwiftUIFlux

extension Int: Identifiable {
    public var id: String {
        String(self)
    }
}

struct ListDetailView: ConnectedView {
    let day: Day
    
    @State private var columnWidths: [Int: CGFloat] = [:]
    @State private var absenceEntriesToDelete: Int?

    struct Props {
        let accentColor: CodableColor
        let timeEntries: [TimeEntry]
        let timeEntryBinding: (Int) -> Binding<TimeEntry>
        let absenceEntries: [AbsenceEntry]
        let absenceEntryBinding: (Int) -> Binding<AbsenceEntry>
        let deleteTimeEntry: (TimeEntry) -> Void
        let deleteAbsenceEntry: (AbsenceEntry, Day?) -> Void
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(accentColor: state.settingsState.accentColor,
                     timeEntries: state.timeState.timeEntries.forDay(self.day),
                     timeEntryBinding: { index in Binding<TimeEntry>(get: { state.timeState.timeEntries.forDay(self.day)[index] },
                                                                     set: { dispatch(UpdateTimeEntry(timeEntry: $0)) }) },
                     absenceEntries: state.timeState.absenceEntries.forDay(self.day),
                     absenceEntryBinding: { index in Binding<AbsenceEntry>(get: { state.timeState.absenceEntries.forDay(self.day)[index] },
                                                                           set: { dispatch(UpdateAbsenceEntry(absenceEntry: $0)) }) },
                     deleteTimeEntry: { dispatch(DeleteTimeEntry(timeEntry: $0)) },
                     deleteAbsenceEntry: { dispatch(DeleteAbsenceEntry(absenceEntry: $0, onlyForDay: $1)) })
    }

    func body(props: Props) -> some View {
        VStack {
            Spacer(minLength: 20)

            ArcViewAverage(timeEntries: [self.day: props.timeEntries],
                           workingDays: [self.day],
                           color: .accentColor)
                .frame(width: 250, height: 250)

            Form {
                Section(header: Text("absences")) {
                    ForEach(props.absenceEntries) { absenceEntry in
                        if let index = props.absenceEntries.firstIndex(of: absenceEntry) {
                            ListDetailRowAbsenceEntryView(absenceEntry: props.absenceEntryBinding(index))
                        }
                    }
                    .onDelete(perform: { indexSet in
                        indexSet.forEach { index in
                            let absenceEntry = props.absenceEntries[index]
                            if absenceEntry.start == absenceEntry.end {
                                props.deleteAbsenceEntry(absenceEntry, nil)
                            } else {
                                self.absenceEntriesToDelete = index
                            }
                        }
                    })
                }
                .alert(item: self.$absenceEntriesToDelete) { index in
                    Alert(title: Text("alertDeleteAbsenceTitle"),
                          message: Text("alertDeleteAbsenceText"),
                          primaryButton: .destructive(Text("alertDeleteAbsenceCompletely")) {
                            let absenceEntry = props.absenceEntries[index]
                            props.deleteAbsenceEntry(absenceEntry, nil)
                          },
                          secondaryButton: .default(Text("alertDeleteAbsenceThisDay")) {
                            let absenceEntry = props.absenceEntries[index]
                            props.deleteAbsenceEntry(absenceEntry, self.day)
                          })
                }

                Section(header: Text("timeEntries")) {
                    ForEach(props.timeEntries) { timeEntry in
                        if let index = props.timeEntries.firstIndex(of: timeEntry) {
                            ListDetailRowTimeEntryView(timeEntry: props.timeEntryBinding(index),
                                                       columnWidths: self.$columnWidths,
                                                       breakDurationBefore: props.timeEntries.getBreak(between: index - 1, and: index),
                                                       breakDurationAfter: props.timeEntries.getBreak(between: index, and: index + 1))
                        }
                    }
                    .onDelete(perform: { indexSet in
                        indexSet.forEach { index in
                            let timeEntry = props.timeEntries[index]
                            props.deleteTimeEntry(timeEntry)
                        }
                    })
                }
            }

        }
        .onPreferenceChange(WidthKey.self) { self.columnWidths = $0 }
        .navigationTitle(self.day.date.formatted("EE, MMM d"))
        .toolbarAddEntry(initialDay: self.day,
                         accentColor: props.accentColor.color)
    }
}

struct ListDetailRowAbsenceEntryView: View {
    @Binding var absenceEntry: AbsenceEntry

    var body: some View {
        VStack {
            HStack {
                Text(self.absenceEntry.type.localizedTitle)
                Spacer()
                Text("5d")
            }
//            HStack {
//                DatePicker("", selection: self.$absenceEntry.start.date, displayedComponents: .date)
//                    .labelsHidden()
//
//                Image(systemName: "arrow.right")
//
//                DatePicker("", selection: self.$absenceEntry.end.date, displayedComponents: .date)
//                    .labelsHidden()
//            }
        }
    }
}

struct SetWidthKeyModifier: ViewModifier {
    let index: Int

    func body(content: Content) -> some View {
        content
            .background(GeometryReader { proxy in
                Color.clear
                    .preference(key: WidthKey.self, value: [self.index: proxy.size.width])
            })
    }
}

extension View {
    func setWidthKey(index: Int) -> some View {
        self.modifier(SetWidthKeyModifier(index: index))
    }
}

struct WidthKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue(), uniquingKeysWith: max)
    }
}

// MARK: - Preview

#if DEBUG
struct TimeEntryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ListDetailView(day: Day().addingDays(-57))
            .environmentObject(previewStore)
            .accentColor(.green)
            .environment(\.colorScheme, .dark)
    }
}
#endif
