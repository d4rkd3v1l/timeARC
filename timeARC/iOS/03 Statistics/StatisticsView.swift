//
//  StatisticsView.swift
//  timeARC
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
        let relevantDays: [Day]
        let workingDuration: Int
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        let startDate = state.statisticsState.selectedStartDate
        let endDate = state.statisticsState.selectedEndDate
        let relevantDays = state.settingsState.workingWeekDays.relevantDays(for: state.timeState.timeEntries,
                                                                            absenceEntries: state.timeState.absenceEntries,
                                                                            considerTimeEntriesOnNonWorkingDays: true,
                                                                            limitStartDate: startDate,
                                                                            limitEndDate: [endDate, Date()].min())

        return Props(timeFrame: state.statisticsState.selectedTimeFrame,
                     startDate: startDate,
                     endDate: endDate,
                     timeEntries: state.timeState.timeEntries.timeEntries(from: startDate,
                                                                          to: endDate),
                     absenceEntries: state.timeState.absenceEntries.exactAbsenceEntries(for: relevantDays,
                                                                                        from: startDate,
                                                                                        to: endDate),
                     relevantDays: relevantDays,
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
                                                       relevantDays: props.relevantDays)
                        }

                        Section {
                            StatisticsWorkingHoursView(startDate: props.startDate,
                                                       endDate: props.endDate,
                                                       timeEntries: props.timeEntries,
                                                       absenceEntries: props.absenceEntries,
                                                       relevantDays: props.relevantDays,
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
                                                   relevantDays: props.relevantDays,
                                                   workingDuration: props.workingDuration)
                        }

                        Section {
                            StatisticsAbsencesView(timeEntries: props.timeEntries,
                                                   absenceEntries: props.absenceEntries,
                                                   relevantDays: props.relevantDays)
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
