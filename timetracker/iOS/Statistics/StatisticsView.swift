//
//  StatisticsView.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 20.09.20.
//

import SwiftUI
import SwiftUIFlux

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

    @ObservedObject var updater = StateUpdater(updateInterval: 60, action: StatisticsRefresh())
    @State private var selectedTimeFrame: TimeFrame = .week

    func body(props: Props) -> some View {
        NavigationView {
            VStack {
                Picker("", selection: self.$selectedTimeFrame) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                        Text(LocalizedStringKey(timeFrame.rawValue)).tag(timeFrame)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.bottom, 10)
                .onChange(of: self.selectedTimeFrame) {
                    store.dispatch(action: StatisticsChangeTimeFrame(timeFrame: $0))
                }

                HStack {
                    Button(action: {
                        store.dispatch(action: StatisticsPreviousInterval())
                    }, label: {
                        Image(systemName: "arrow.left.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                            .padding(.all, 10)
                    })
                    .disabled(props.timeFrame == .allTime)

                    Text(self.dateText(timeFrame: props.timeFrame, startDate: props.startDate, endDate: props.endDate))

                    Button(action: {
                        store.dispatch(action: StatisticsNextInterval())
                    }, label: {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                            .padding(.all, 10)
                    })
                    .disabled(props.timeFrame == .allTime)
                }

                if let errorMessage = self.errorMessage(timeEntries: props.timeEntries, absenceEntries: props.absenceEntries) {
                    Text(LocalizedStringKey(errorMessage))
                        .multilineTextAlignment(.center)
                        .padding(.all, 50)
                    Spacer()
                } else {
                    List {
                        Section(header: Text("averages")) {
                            VStack {
                                ZStack {
                                    HStack {
                                        ArcViewFull(duration: props.timeEntries.averageDuration(workingDays: props.workingDays),
                                                    maxDuration: props.workingDuration,
                                                    color: .accentColor,
                                                    allowedUnits: [.hour, .minute],
                                                    displayMode: .countUp)
                                            .frame(width: 150, height: 150)
                                        Spacer()
                                    }
                                    HStack {
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            Text("workingHours")
                                            Spacer()
                                            Text("\(props.timeEntries.averageWorkingHoursStartDate().formattedTime()) - \(props.timeEntries.averageWorkingHoursEndDate().formattedTime())")
                                        }
                                    }
                                }
                                .padding(.top, 5)
                            }

                            HStack {
                                Text("breaks")
                                Spacer()
                                Text("\(props.timeEntries.averageBreaksDuration(workingDays: props.workingDays).formatted(allowedUnits: [.hour, .minute]) ?? "")")
                            }

                            HStack {
                                Text("overtime")
                                Spacer()
                                Text("\(props.timeEntries.averageOvertimeDuration(workingDays: props.workingDays, workingDuration: props.workingDuration).formatted(allowedUnits: [.hour, .minute]) ?? "")")
                            }
                        }

                        Section(header: Text("Totals")) {
                            VStack {
                                HStack {
                                    ArcViewFull(duration: props.timeEntries.count,
                                                maxDuration: props.workingDays.count,
                                                color: .accentColor,
                                                allowedUnits: [.second],
                                                displayMode: .progress)
                                        .frame(width: 150, height: 150)
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("daysWorked")
                                        Spacer()
                                    }
                                }
                                .padding(.top, 5)
                            }

                            HStack {
                                Text("workingHours")
                                Spacer()
                                Text("\(props.timeEntries.totalDuration(workingDays: props.workingDays, workingDuration: props.workingDuration, absenceEntries: props.absenceEntries).formatted(allowedUnits: [.hour, .minute]) ?? "")")
                            }

                            HStack {
                                Text("breaks")
                                Spacer()
                                Text("\(props.timeEntries.totalBreaksDuration(workingDays: props.workingDays).formatted(allowedUnits: [.hour, .minute]) ?? "")")
                            }

                            HStack {
                                Text("overtime")
                                Spacer()
                                Text("\(props.timeEntries.totalOvertimeDuration(workingDays: props.workingDays, workingDuration: props.workingDuration, absenceEntries: props.absenceEntries).formatted(allowedUnits: [.hour, .minute]) ?? "")")
                            }
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

    private func dateText(timeFrame: TimeFrame,
                          startDate: Date,
                          endDate: Date) -> String {
        switch timeFrame {
        case .week:
            return "\(startDate.formatted("dd.MM.")) - \(endDate.formatted("dd.MM.yyyy")) (\(Calendar.current.component(.weekOfYear, from: startDate)))"

        case .month:
            return startDate.formatted("MMMM yyyy")

        case .year:
            return startDate.formatted("yyyy")

        case .allTime:
            return  "\(startDate.formatted("dd.MM.yyyy")) - \(endDate.formatted("dd.MM.yyyy"))"
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
        store.dispatch(action: AddTimeEntry(timeEntry: TimeEntry(start: formatter.date(from: "01.01.2020 08:27")!, end: formatter.date(from: "01.01.2020 12:13")!)))
        store.dispatch(action: AddTimeEntry(timeEntry: TimeEntry(start: formatter.date(from: "01.01.2020 12:54")!, end: formatter.date(from: "01.01.2020 18:30")!)))
        store.dispatch(action: AddTimeEntry(timeEntry: TimeEntry(start: formatter.date(from: "04.01.2020 08:27")!, end: formatter.date(from: "04.01.2020 12:13")!)))

        return StoreProvider(store: store) {
            StatisticsView()
                .accentColor(.green)
                .environment(\.colorScheme, .dark)
        }
    }
}
