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
        let accentColor: CodableColor
        let timeEntries: [Day: [TimeEntry]]
        let absenceEntries: [AbsenceEntry]
        let absenceTypes: [AbsenceType]
        let relevantDays: [Date : [Dictionary<Date, [Day]>.Element]]
        let workingWeekDays: [WeekDay]
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(accentColor: state.settingsState.accentColor,
                     timeEntries: state.timeState.timeEntries,
                     absenceEntries: state.timeState.absenceEntries,
                     absenceTypes: state.settingsState.absenceTypes,
                     relevantDays: self.group(state.settingsState.workingWeekDays.relevantDays(for: state.timeState.timeEntries, absenceEntries: state.timeState.absenceEntries)),
                     workingWeekDays: state.settingsState.workingWeekDays)
    }

    func body(props: Props) -> some View {
        NavigationView {
            VStack {
                if props.timeEntries.isEmpty {
                    Text("noEntriesYet")
                        .padding(.all, 50)
                        .multilineTextAlignment(.center)
                    Spacer()
                } else {
                    List {
                        ForEach(props.relevantDays.sorted(by: { $0.key > $1.key }), id: \.key) { year, weeks in
                            YearView(year: year,
                                     relevantDays: weeks,
                                     workingWeekDays: props.workingWeekDays,
                                     timeEntries: props.timeEntries,
                                     absenceEntries: props.absenceEntries)
                        }
                    }
                }
            }
            .navigationBarTitle("list")
            .toolbarAddEntry(initialDay: Day(),
                             accentColor: props.accentColor.color)
        }
    }

    func group(_ workingDays: [Day]) -> [Date : [Dictionary<Date, [Day]>.Element]] {
        let byWeeks = Dictionary(grouping: workingDays, by: { $0.date.firstOfWeek })
        let byYears = Dictionary(grouping: byWeeks, by: { $0.key.firstOfYear })
        return byYears
    }
}

private struct YearView: View {
    let year: Date
    let relevantDays: [Dictionary<Date, [Day]>.Element]
    let workingWeekDays: [WeekDay]
    let timeEntries: [Day: [TimeEntry]]
    let absenceEntries: [AbsenceEntry]

    var body: some View {
        Section(header: Text(String(Calendar.current.dateComponents([.year], from: self.year).year ?? 0))) {
            let weeks = self.relevantDays.sorted(by: { $0.key > $1.key })
                .filter { week in
                    !Set(self.timeEntries.map { $0.key }).isDisjoint(with: Set(week.value))
                        || !Set(self.absenceEntries.flatMap { $0.relevantDays(for: week.value) }).isDisjoint(with: Set(week.value))
                }

            ForEach(weeks, id: \.key) { week, days in
                WeekView(week: week,
                         relevantDays: days,
                         workingWeekDays: self.workingWeekDays,
                         timeEntries: timeEntries,
                         absenceEntries: absenceEntries)
            }
        }
    }
}

private struct WeekView: View {
    let week: Date
    let relevantDays: [Day]
    let workingWeekDays: [WeekDay]
    let timeEntries: [Day: [TimeEntry]]
    let absenceEntries: [AbsenceEntry]

    var body: some View {
        Section(header: Text("Week \(Calendar.current.dateComponents([.weekOfYear], from: self.week).weekOfYear ?? 0)")) {
            let days = self.relevantDays.sorted(by: { $0 > $1 })
                .filter {
                    !self.timeEntries.forDay($0).isEmpty
                    || !self.absenceEntries.forDay($0, workingDays: self.relevantDays).isEmpty
                }

            ForEach(days) { day in
                DayView(day: day,
                        relevantDays: relevantDays,
                        workingWeekDays: self.workingWeekDays,
                        timeEntries: self.timeEntries.forDay(day),
                        absenceEntries: self.absenceEntries.forDay(day, workingDays: self.relevantDays))
            }
        }
    }
}

private struct DayView: View {
    let day: Day
    let relevantDays: [Day]
    let workingWeekDays: [WeekDay]
    let timeEntries: [TimeEntry]
    let absenceEntries: [AbsenceEntry]

    var body: some View {
        let weekday = Calendar.current.component(.weekday, from: self.day.date)
        let showAbsenceEntries = workingWeekDays.contains(WeekDay(weekday))

        NavigationLink(destination: ListDetailView(day: self.day)) {
            ListRowView(day: self.day,
                        timeEntries: self.timeEntries,
                        absenceEntries: showAbsenceEntries ? self.absenceEntries : [])
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
            .environmentObject(previewStore)
            .accentColor(.green)
            .environment(\.colorScheme, .dark)
    }
}
#endif
