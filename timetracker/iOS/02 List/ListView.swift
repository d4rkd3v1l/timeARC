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
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(accentColor: state.settingsState.accentColor,
                     timeEntries: state.timeState.timeEntries,
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
                        ForEach(props.timeEntries.sorted(by: { $0.key > $1.key }), id: \.key) { day, timeEntries in
                            NavigationLink(destination: ListDetailView(day: day)) {
                                ListRowView(day: day,
                                            timeEntries: timeEntries,
                                            absenceEntries: props.absenceEntries.forDay(day))
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
