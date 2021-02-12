//
//  StatisticsTimeFrameView.swift
//  timeARC
//
//  Created by d4Rk on 12.02.21.
//

import SwiftUI
import SwiftUIFlux

struct StatisticsTimeFrameView: ConnectedView {
    struct Props {
        let timeFrame: TimeFrame
        let startDate: Date
        let endDate: Date
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(timeFrame: state.statisticsState.selectedTimeFrame,
                     startDate: state.statisticsState.selectedStartDate,
                     endDate: state.statisticsState.selectedEndDate)
    }

    @Binding private var selectedTimeFrame: TimeFrame

    init(selectedTimeFrame: Binding<TimeFrame>) {
        self._selectedTimeFrame = selectedTimeFrame
    }

    func body(props: Props) -> some View {
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

                if stride(from: props.startDate, through: props.endDate, by: 86400).map({ $0.day }).contains(Day()) {
                    Text(self.dateText(timeFrame: props.timeFrame, startDate: props.startDate, endDate: props.endDate))
                        .bold()
                } else {
                    Text(self.dateText(timeFrame: props.timeFrame, startDate: props.startDate, endDate: props.endDate))
                }

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
}
