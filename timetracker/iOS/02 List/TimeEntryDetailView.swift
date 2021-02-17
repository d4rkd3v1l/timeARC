//
//  NewListDayView.swift
//  timeARC
//
//  Created by d4Rk on 13.02.21.
//

import SwiftUI
import SwiftUIFlux

private var formatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy HH:mm"
    return formatter
}

struct TimeEntryDetailView: ConnectedView {
    let day: Day
    
    @State private var columnWidths: [Int: CGFloat] = [:]

    struct Props {
        let timeEntries: [TimeEntry]
        let absenceEntries: [AbsenceEntry]
        let updateTimeEntry: (TimeEntry) -> Void
        let timeEntryBinding: (Int) -> Binding<TimeEntry>
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(timeEntries: state.timeState.timeEntries.forDay(self.day),
                     absenceEntries: state.timeState.absenceEntries,
                     updateTimeEntry: { dispatch(UpdateTimeEntry(timeEntry: $0)) },
                     timeEntryBinding: { index in Binding<TimeEntry>(get: { state.timeState.timeEntries.forDay(self.day)[index] },
                                                                     set: { dispatch(UpdateTimeEntry(timeEntry: $0)) }) })
    }

    func body(props: Props) -> some View {
            VStack {
                Spacer(minLength: 20)

                ArcViewAverage(timeEntries: [self.day: props.timeEntries],
                               workingDays: [self.day],
                               color: .accentColor)
                    .frame(width: 250, height: 250)

                Form {
                    ForEach(0..<props.timeEntries.count) { index in
                        TimeEntryDetailRowView(timeEntry: props.timeEntryBinding(index),
                                               columnWidths: self.$columnWidths,
                                               breakDurationBefore: props.timeEntries.getBreak(between: index - 1, and: index),
                                               breakDurationAfter: props.timeEntries.getBreak(between: index, and: index + 1))
                    }
                    .onDelete(perform: { indexSet in
                        indexSet.forEach { index in
//                            let absenceEntry = self.absenceEntries[index]
//                            store.dispatch(action: DeleteAbsenceEntry(absenceEntry: absenceEntry, onlyForDay: self.day))
                        }
                    })
                }

            }
            .onPreferenceChange(WidthKey.self) { self.columnWidths = $0 }
            .navigationTitle(self.day.date.formatted("EE, MMM d"))
    }
}

struct TimeEntryDetailRowView: View {
    @Binding var timeEntry: TimeEntry
    @Binding var columnWidths: [Int: CGFloat]

    let breakDurationBefore: Int?
    let breakDurationAfter: Int?

    var body: some View {
        ZStack {
            HStack {
                DatePicker("", selection: self.$timeEntry.start, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .setWidthKey(index: 0)
                    .frame(width: self.columnWidths[0], alignment: .leading)

                Image(systemName: "arrow.right")

                DatePicker("", selection:  self.$timeEntry.end ?? Date(), displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .setWidthKey(index: 1)
                    .frame(width: self.columnWidths[1], alignment: .leading)

                Spacer()

                Text(self.timeEntry.durationFormatted() ?? "")
            }
            .padding(.vertical, 7)

            HStack {
                Spacer()
                ZStack {
                    if let breakDurationBefore = breakDurationBefore {
                        HStack(spacing: 5) {
                            Text("break")
                            Text(breakDurationBefore.formatted() ?? "")
                        }
                        .font(.caption2)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .foregroundColor(.primary)
                        .background(Color.tertiarySystemGroupedBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .offset(x: 15, y: -30)
                    }

                    if let breakDurationAfter = breakDurationAfter {
                        HStack(spacing: 5) {
                            Text("break").padding(0)
                            Text(breakDurationAfter.formatted() ?? "")
                        }
                        .font(.caption2)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .foregroundColor(.primary)
                        .background(Color.tertiarySystemGroupedBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .offset(x: 15, y: 30)
                    }
                }
            }
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

struct TimeEntryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TimeEntryDetailView(day: Day())
            .accentColor(.green)
//            .environment(\.colorScheme, .dark)
    }
}
