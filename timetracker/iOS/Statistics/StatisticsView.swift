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
        let selectedTimeFrame: TimeFrame
        let selectedDateText: String
        let errorMessage: String?
        let targetDuration: Int
        let averageDuration: Int
        let averageWorkingHoursStartDate: Date
        let averageWorkingHoursEndDate: Date
        let averageBreaksDuration: Int
        let averageOvertimeDuration: Int
        let totalDays: Int
        let totalDaysWorked: Int
        let totalDuration: Int
        let totalBreaksDuration: Int
        let totalOvertimeDuration: Int
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(selectedTimeFrame: state.statisticsState.selectedTimeFrame,
                     selectedDateText: state.statisticsState.selectedDateText,
                     errorMessage: state.statisticsState.errorMessage,
                     targetDuration: state.statisticsState.targetDuration,
                     averageDuration: state.statisticsState.averageDuration,
                     averageWorkingHoursStartDate: state.statisticsState.averageWorkingHoursStartDate,
                     averageWorkingHoursEndDate: state.statisticsState.averageWorkingHoursEndDate,
                     averageBreaksDuration: state.statisticsState.averageBreaksDuration,
                     averageOvertimeDuration: state.statisticsState.averageOvertimeDuration,
                     totalDays: state.statisticsState.totalDays,
                     totalDaysWorked: state.statisticsState.totalDaysWorked,
                     totalDuration: state.statisticsState.totalDuration,
                     totalBreaksDuration: state.statisticsState.totalBreaksDuration,
                     totalOvertimeDuration: state.statisticsState.totalOvertimeDuration)
    }

    @ObservedObject var updater = StateUpdater(updateInterval: 60, action: StatisticsRefresh())
    @State private var selectedTimeFrame: TimeFrame = .allTime

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
                            .padding(.all, 15)
                    })
                    .disabled(props.selectedTimeFrame == .allTime)

                    Text(props.selectedDateText)

                    Button(action: {
                        store.dispatch(action: StatisticsNextInterval())
                    }, label: {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                            .padding(.all, 15)
                    })
                    .disabled(props.selectedTimeFrame == .allTime)
                }

                if let errorMessage = props.errorMessage {
                    Text(LocalizedStringKey(errorMessage))
                        .multilineTextAlignment(.center)
                        .padding(.all, 50)
                    Spacer()
                } else {
                    List {
                        Section(header: Text("averages")) {
                            VStack {
                                HStack {
                                    ArcViewFull(duration: props.averageDuration, maxDuration: props.targetDuration, color: .accentColor, allowedUnits: [.hour, .minute], displayMode: .countUp)
                                        .frame(width: 150, height: 150)
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("workingHours")
                                        Spacer()
                                        Text("\(props.averageWorkingHoursStartDate.formatted("HH:mm")) - \(props.averageWorkingHoursEndDate.formatted("HH:mm"))")
                                    }
                                }
                            }

                            HStack {
                                Text("breaks")
                                Spacer()
                                Text("\(props.averageBreaksDuration.formatted(allowedUnits: [.hour, .minute]) ?? "")")
                            }

                            HStack {
                                Text("overtime")
                                Spacer()
                                Text("\(props.averageOvertimeDuration.formatted(allowedUnits: [.hour, .minute]) ?? "")")

                            }
                        }

                        Section(header: Text("Totals")) {
                            VStack {
                                HStack {
                                    ArcViewFull(duration: props.totalDaysWorked, maxDuration: props.totalDays, color: .accentColor, allowedUnits: [.second], displayMode: .progress)
                                        .frame(width: 150, height: 150)
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("daysWorked")
                                        Spacer()
                                    }
                                }
                            }

                            HStack {
                                Text("workingHours")
                                Spacer()
                                Text("\(props.totalDuration.formatted(allowedUnits: [.hour, .minute]) ?? "")")

                            }

                            HStack {
                                Text("breaks")
                                Spacer()
                                Text("\(props.totalBreaksDuration.formatted(allowedUnits: [.hour, .minute]) ?? "")")

                            }

                            HStack {
                                Text("overtime")
                                Spacer()
                                Text("\(props.totalOvertimeDuration.formatted(allowedUnits: [.hour, .minute]) ?? "")")

                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationBarTitle("statistics")
        }
        .onAppear {
            self.selectedTimeFrame = props.selectedTimeFrame
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        store.dispatch(action: InitFlux())

        return StoreProvider(store: store) {
            StatisticsView()
                .accentColor(.green)
                .environment(\.colorScheme, .dark)
        }
    }
}
