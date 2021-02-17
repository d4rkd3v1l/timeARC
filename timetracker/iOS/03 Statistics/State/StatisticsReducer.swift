//
//  StatisticsState.swift
//  timetracker
//
//  Created by d4Rk on 20.09.20.
//

import SwiftUI
import SwiftUIFlux

func statisticsReducer(appState: AppState, action: Action) -> StatisticsState {
    var state = appState.statisticsState

    switch action {
    case let action as StatisticsChangeTimeFrame:
        state.selectedTimeFrame = action.timeFrame

        switch action.timeFrame {
        case .week:
            state.selectedStartDate = Date().firstOfWeek
            state.selectedEndDate = Date().lastOfWeek

        case .month:
            state.selectedStartDate = Date().firstOfMonth
            state.selectedEndDate = Date().lastOfMonth

        case .year:
            state.selectedStartDate = Date().firstOfYear
            state.selectedEndDate = Date().lastOfYear

        case .allTime:
            let sortedTimeEntries = appState.timeState.timeEntries.sorted(by: { $0.key < $1.key })
            let startDate = sortedTimeEntries.first?.value.first?.start ?? Date(timeIntervalSince1970: 0)
            let endDate = sortedTimeEntries.last?.value.last?.actualEnd ?? Date()
            state.selectedStartDate = startDate
            state.selectedEndDate = endDate
        }

    case _ as StatisticsNextInterval:
        switch state.selectedTimeFrame {
        case .week:
            state.selectedStartDate = state.selectedStartDate.byAdding(DateComponents(weekOfYear: 1)).firstOfWeek
            state.selectedEndDate = state.selectedStartDate.lastOfWeek

        case .month:
            state.selectedStartDate = state.selectedStartDate.byAdding(DateComponents(month: 1)).firstOfMonth
            state.selectedEndDate = state.selectedStartDate.lastOfMonth

        case .year:
            state.selectedStartDate = state.selectedStartDate.byAdding(DateComponents(year: 1)).firstOfYear
            state.selectedEndDate = state.selectedStartDate.lastOfYear

        case .allTime:
            break
        }

    case _ as StatisticsPreviousInterval:
        switch state.selectedTimeFrame {
        case .week:
            state.selectedStartDate = state.selectedStartDate.byAdding(DateComponents(weekOfYear: -1)).firstOfWeek
            state.selectedEndDate = state.selectedStartDate.lastOfWeek

        case .month:
            state.selectedStartDate = state.selectedStartDate.byAdding(DateComponents(month: -1)).firstOfMonth
            state.selectedEndDate = state.selectedStartDate.lastOfMonth

        case .year:
            state.selectedStartDate = state.selectedStartDate.byAdding(DateComponents(year: -1)).firstOfYear
            state.selectedEndDate = state.selectedStartDate.lastOfYear

        case .allTime:
            break
        }

    default:
        break
    }

    return state
}
