//
//  NewListDayView.swift
//  timeARC
//
//  Created by d4Rk on 13.02.21.
//

import SwiftUI
import SwiftUIFlux

// TODO: unhack!
extension Int: Identifiable {
    public var id: String {
        String(self)
    }
}

struct ListDetailView: ConnectedView {
    let day: Day

    @Environment(\.presentationMode) var presentationMode
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
                     timeEntryBinding: { index in
                        Binding<TimeEntry>(get: { state.timeState.timeEntries.forDay(self.day)[index] },
                                           set: { dispatch(UpdateTimeEntry(timeEntry: $0)) }) },
                     absenceEntries: state.timeState.absenceEntries.forDay(self.day),
                     absenceEntryBinding: { index in
                        Binding<AbsenceEntry>(get: { state.timeState.absenceEntries.forDay(self.day)[index] },
                                              set: { dispatch(UpdateAbsenceEntry(absenceEntry: $0)) }) },
                     deleteTimeEntry: { dispatch(DeleteTimeEntry(timeEntry: $0)) },
                     deleteAbsenceEntry: { dispatch(DeleteAbsenceEntry(absenceEntry: $0, onlyForDay: $1)) })
    }

    func body(props: Props) -> some View {
        if props.timeEntries.isEmpty && props.absenceEntries.isEmpty {
            self.presentationMode.wrappedValue.dismiss()
        }

        return VStack {
            Form {
                if !props.timeEntries.isEmpty {
                    Section(header: OptionalText("timeEntries", condition: !props.absenceEntries.isEmpty)) {
                        HStack {
                            Spacer()
                            ArcViewAverage(timeEntries: props.timeEntries,
                                           color: .accentColor)
                                .frame(width: 250, height: 250)
                            Spacer()
                        }
                        .padding(.top, 20)

                        ForEach(props.timeEntries) { timeEntry in
                            if let index = props.timeEntries.firstIndex(where: { $0.id == timeEntry.id }) {
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

                if !props.absenceEntries.isEmpty {
                    Section(header: OptionalText("absences", condition: !props.timeEntries.isEmpty)) {
                        ForEach(props.absenceEntries) { absenceEntry in
                            if let index = props.absenceEntries.firstIndex(where: { $0.id == absenceEntry.id }) {
                                ListDetailRowAbsenceEntryView(absenceEntry: props.absenceEntries[index])
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
                }
            }
        }
        .onPreferenceChange(WidthKey.self) { self.columnWidths = $0 }
        .navigationTitle(self.day.date.formatted("EE, MMM d"))
        .toolbarAddEntry(initialDay: self.day,
                         accentColor: props.accentColor.color)
    }
}

struct OptionalText: View {
    let text: LocalizedStringKey
    let condition: Bool

    init(_ text: LocalizedStringKey, condition: Bool) {
        self.text = text
        self.condition = condition
    }

    var body: some View {
        if self.condition {
            Text(self.text)
        } else {
            EmptyView()
        }
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
