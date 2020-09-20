//
//  StatisticsState.swift
//  timetracker
//
//  Created by d4Rk on 20.09.20.
//

import SwiftUI
import SwiftUIFlux

func statisticsReducer(state: StatisticsState, action: Action) -> StatisticsState {
    var state = state

    switch action {
    case let action as StatisticsChangeTimeFrame:
        state.selectedTimeFrame = action.timeFrame

        switch action.timeFrame {
        case .all:
            state.selectedStartDate = Date(timeIntervalSince1970: 0)
            state.selectedEndDate = Date()

        case .year:
            state.selectedStartDate = Date().firstOfYear
            state.selectedEndDate = Date().lastOfYear

        case .month:
            state.selectedStartDate = Date().firstOfMonth
            state.selectedEndDate = Date().lastOfMonth

        case .week:
            state.selectedStartDate = Date().firstOfWeek
            state.selectedEndDate = Date().lastOfWeek
        }

    case _ as StatisticsNextInterval:
        switch state.selectedTimeFrame {
        case .all:
            break

        case .year:
            state.selectedStartDate = state.selectedStartDate.byAdding(DateComponents(year: 1)).firstOfYear
            state.selectedEndDate = state.selectedStartDate.lastOfYear

        case .month:
            state.selectedStartDate = state.selectedStartDate.byAdding(DateComponents(month: 1)).firstOfMonth
            state.selectedEndDate = state.selectedStartDate.lastOfMonth

        case .week:
            state.selectedStartDate = state.selectedStartDate.byAdding(DateComponents(weekOfYear: 1)).firstOfWeek
            state.selectedEndDate = state.selectedStartDate.lastOfWeek
        }

    case _ as StatisticsPreviousInterval:
        switch state.selectedTimeFrame {
        case .all:
            break

        case .year:
            state.selectedStartDate = state.selectedStartDate.byAdding(DateComponents(year: -1)).firstOfYear
            state.selectedEndDate = state.selectedStartDate.lastOfYear

        case .month:
            state.selectedStartDate = state.selectedStartDate.byAdding(DateComponents(month: -1)).firstOfMonth
            state.selectedEndDate = state.selectedStartDate.lastOfMonth

        case .week:
            state.selectedStartDate = state.selectedStartDate.byAdding(DateComponents(weekOfYear: -1)).firstOfWeek
            state.selectedEndDate = state.selectedStartDate.lastOfWeek
        }

    default:
        break
    }

    return state
}
