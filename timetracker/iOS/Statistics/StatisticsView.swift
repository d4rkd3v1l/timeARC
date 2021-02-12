//
//  StatisticsView.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 20.09.20.
//

import SwiftUI
import SwiftUIFlux
import SwiftUICharts

enum TimeFrame: String, CaseIterable, Identifiable, Codable {
    case week
    case month
    case year
    case allTime

    var id: String {
        return self.rawValue
    }
}

struct StatisticsView: ConnectedView {
    struct Props {
        let timeFrame: TimeFrame
        let startDate: Date
        let endDate: Date
        let timeEntries: [Day: [TimeEntry]]
        let absenceEntries: [AbsenceEntry]
        let workingDays: [Day]
        let workingDuration: Int
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(timeFrame: state.statisticsState.selectedTimeFrame,
                     startDate: state.statisticsState.selectedStartDate,
                     endDate: state.statisticsState.selectedEndDate,
                     timeEntries: state.timeState.timeEntries
                        .timeEntries(from: state.statisticsState.selectedStartDate,
                                     to: state.statisticsState.selectedEndDate),
                     absenceEntries: state.timeState.absenceEntries
                        .exactAbsenceEntries(from: state.statisticsState.selectedStartDate,
                                             to: state.statisticsState.selectedEndDate),
                     workingDays: state.settingsState.workingWeekDays
                        .workingDays(startDate: state.statisticsState.selectedStartDate,
                                     endDate: state.statisticsState.selectedEndDate),
                     workingDuration: state.settingsState.workingDuration)
    }

//    @ObservedObject var updater = StateUpdater(updateInterval: 60, action: StatisticsRefresh())
    @State private var selectedTimeFrame: TimeFrame = .week

    func body(props: Props) -> some View {
        NavigationView {
            VStack {
                StatisticsTimeFrameView(selectedTimeFrame: self.$selectedTimeFrame)

                if let errorMessage = self.errorMessage(timeEntries: props.timeEntries, absenceEntries: props.absenceEntries) {
                    Text(LocalizedStringKey(errorMessage))
                        .multilineTextAlignment(.center)
                        .padding(.all, 50)
                    Spacer()
                } else {
                    List {
                        Section {
                            StatisticsAverageHoursView(timeEntries: props.timeEntries,
                                                       workingDays: props.workingDays)
                        }

                        Section {
                            StatisticsWorkingHoursView(startDate: props.startDate,
                                                       endDate: props.endDate,
                                                       timeEntries: props.timeEntries,
                                                       absenceEntries: props.absenceEntries,
                                                       workingDays: props.workingDays,
                                                       workingDuration: props.workingDuration)
                        }

                        Section {
                            StatisticsBreaksView(startDate: props.startDate,
                                                 endDate: props.endDate,
                                                 timeEntries: props.timeEntries)
                        }

                        Section {
                            StatisticsOvertimeView(startDate: props.startDate,
                                                   endDate: props.endDate,
                                                   timeEntries: props.timeEntries,
                                                   absenceEntries: props.absenceEntries,
                                                   workingDays: props.workingDays,
                                                   workingDuration: props.workingDuration)
                        }

                        Section {
                            StatisticsAbsencesView(timeEntries: props.timeEntries,
                                                   absenceEntries: props.absenceEntries,
                                                   workingDays: props.workingDays)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationBarTitle("statistics")
        }
        .onAppear {
            self.selectedTimeFrame = props.timeFrame
        }
    }

    private func errorMessage(timeEntries: [Day: [TimeEntry]], absenceEntries: [AbsenceEntry]) -> String? {
        if timeEntries.isEmpty && absenceEntries.isEmpty {
            return "noStatisticsForTimeFrameMessage"
        }

        return nil
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        store.dispatch(action: InitFlux())

        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        store.dispatch(action: AddTimeEntry(timeEntry: TimeEntry(start: formatter.date(from: "01.02.2021 08:27")!, end: formatter.date(from: "01.02.2021 12:13")!)))
        store.dispatch(action: AddTimeEntry(timeEntry: TimeEntry(start: formatter.date(from: "01.02.2021 12:54")!, end: formatter.date(from: "01.02.2021 18:30")!)))
        store.dispatch(action: AddTimeEntry(timeEntry: TimeEntry(start: formatter.date(from: "04.02.2021 08:27")!, end: formatter.date(from: "04.02.2021 12:13")!)))

        store.dispatch(action: AddAbsenceEntry(absenceEntry: AbsenceEntry(type: .dummy, start: formatter.date(from: "01.02.2021 08:27")!.day, end: formatter.date(from: "02.02.2021 08:27")!.day)))

        return StoreProvider(store: store) {
            StatisticsView()
                .accentColor(.green)
                .environment(\.colorScheme, .dark)
        }
    }
}
