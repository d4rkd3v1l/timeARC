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
        let timeEntries: [Date: [Dictionary<Date, [Dictionary<Day, [TimeEntry]>.Element]>.Element]]
        let absenceEntries: [AbsenceEntry]
        let absenceTypes: [AbsenceType]
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(accentColor: state.settingsState.accentColor,
                     timeEntries: self.group(state.timeState.timeEntries),
                     absenceEntries: state.timeState.absenceEntries,
                     absenceTypes: state.settingsState.absenceTypes)
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
                        ForEach(props.timeEntries.sorted(by: { $0.key > $1.key }), id: \.key) { year, timeEntries in
                            Section(header: Text(String(Calendar.current.dateComponents([.year], from: year).year ?? 0))) {
                                ForEach(timeEntries.sorted(by: { $0.key > $1.key }), id: \.key) { week, timeEntries in
                                    Section(header: Text("Week \(Calendar.current.dateComponents([.weekOfYear], from: week).weekOfYear ?? 0)")) {
                                        ForEach(timeEntries.sorted(by: { $0.key > $1.key }), id: \.key) { day, timeEntries in
                                            NavigationLink(destination: ListDetailView(day: day)) {
                                                ListRowView(day: day,
                                                            timeEntries: timeEntries,
                                                            absenceEntries: props.absenceEntries.forDay(day))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("list")
            .toolbarAddEntry(initialDay: Day(),
                             accentColor: props.accentColor.color)
        }
    }


    func group(_ timeEntries: [Day: [TimeEntry]]) -> [Date: [Dictionary<Date, [Dictionary<Day, [TimeEntry]>.Element]>.Element]] {
        let byWeeks = Dictionary(grouping: timeEntries, by: {
            $0.key.date.firstOfWeek
        })

        let byYears = Dictionary(grouping: byWeeks, by: {
            $0.key.firstOfYear
        })

        return byYears
    }
}

struct Year {
    let year: Int
    let entries: [Week]
}

struct Week {
    let week: Int
    let entries: [Day: [TimeEntry]]
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
