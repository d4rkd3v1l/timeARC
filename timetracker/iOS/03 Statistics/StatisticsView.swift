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
    @State private var selectedTimeFrame: TimeFrame = .week
    
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
        let startDate = state.statisticsState.selectedStartDate
        let endDate = state.statisticsState.selectedEndDate
        let workingDays = state.settingsState.workingWeekDays.workingDays(startDate: startDate, endDate: endDate)

        return Props(timeFrame: state.statisticsState.selectedTimeFrame,
                     startDate: startDate,
                     endDate: endDate,
                     timeEntries: state.timeState.timeEntries.timeEntries(from: startDate,
                                                                          to: endDate),
                     absenceEntries: state.timeState.absenceEntries.exactAbsenceEntries(for: workingDays,
                                                                                        from: startDate,
                                                                                        to: endDate),
                     workingDays: state.settingsState.workingWeekDays.workingDays(startDate: startDate,
                                                                                  endDate: endDate),
                     workingDuration: state.settingsState.workingDuration)
    }

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

// MARK: - Preview

#if DEBUG
struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
            .environmentObject(previewStore)
            .accentColor(.green)
            .environment(\.colorScheme, .dark)
    }
}
#endif
