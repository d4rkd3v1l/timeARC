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
        case .allTime:
            let sortedTimeEntries = state.timeEntries.sorted(by: { $0.key < $1.key })
            let startDate = sortedTimeEntries.first?.value.first?.start ?? Date(timeIntervalSince1970: 0)
            let endDate = sortedTimeEntries.last?.value.last?.actualEnd ?? Date()
            state.selectedStartDate = startDate
            state.selectedEndDate = endDate

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

        ensureStatistics(&state)

    case _ as StatisticsNextInterval:
        switch state.selectedTimeFrame {
        case .allTime:
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

        ensureStatistics(&state)

    case _ as StatisticsPreviousInterval:
        switch state.selectedTimeFrame {
        case .allTime:
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

        ensureStatistics(&state)

    case _ as StatisticsRefresh:
        ensureStatistics(&state)

    default:
        break
    }

    return state
}

private func ensureStatistics(_ state: inout StatisticsState) {
    switch state.selectedTimeFrame {
    case .allTime:
        state.selectedDateText = "\(state.selectedStartDate.formatted("dd.MM.yyyy")) - \(state.selectedEndDate.formatted("dd.MM.yyyy"))"

    case .year:
        state.selectedDateText = state.selectedStartDate.formatted("yyyy")

    case .month:
        state.selectedDateText = state.selectedStartDate.formatted("MMMM yyyy")

    case .week:
        state.selectedDateText = "\(state.selectedStartDate.formatted("dd.MM.")) - \(state.selectedEndDate.formatted("dd.MM.yyyy")) (\(Calendar.current.component(.weekOfYear, from: state.selectedStartDate)))"
    }

    let relevantTimeEntries = state.timeEntries.filter {
        (state.selectedStartDate.startOfDay...state.selectedEndDate.endOfDay).contains($0.key)
    }

    guard !relevantTimeEntries.isEmpty else {
        state.errorMessage = "noStatisticsForTimeFrameMessage"
        return
    }

    state.errorMessage = nil
    state.targetDuration = state.workingMinutesPerDay * 60

    let totalDurationInSeconds = relevantTimeEntries
        .map { _, timeEntries in
            timeEntries.totalDurationInSeconds
        }

    state.averageDuration = totalDurationInSeconds.average()
    state.totalDuration = totalDurationInSeconds.sum()

    state.averageWorkingHoursStartDate = relevantTimeEntries
        .compactMap { day, timeEntries in
            timeEntries.first?.start
        }
        .averageTime

    state.averageWorkingHoursEndDate = relevantTimeEntries
        .compactMap { day, timeEntries in
            timeEntries.last?.end
        }
        .averageTime

    let totalBreaksInSeconds = relevantTimeEntries
        .map { _, timeEntries in
            timeEntries.totalBreaksInSeconds
        }

    state.averageBreaksDuration = totalBreaksInSeconds.average()
    state.totalBreaksDuration = totalBreaksInSeconds.sum()

    let totalOvertimeInSeconds = relevantTimeEntries
        .map { _, timeEntries in
            // TODO: consider missing days! #absenceTypes
            timeEntries.totalDurationInSeconds - (state.workingMinutesPerDay * 60)
        }

    state.averageOvertimeDuration = totalOvertimeInSeconds.average()
    state.totalOvertimeDuration = totalOvertimeInSeconds.sum()

    state.totalDays = stride(from: state.selectedStartDate.startOfDay,
                             through: state.selectedEndDate.endOfDay,
                             by: 86400)
        .reduce(0) { result, current in
            let isCurrentDayAWorkingDay = state.workingWeekDays.contains(WeekDay(Calendar.current.component(.weekday, from: current)))
            return result + (isCurrentDayAWorkingDay ? 1 : 0)
        }

    state.totalDaysWorked = relevantTimeEntries.count
}
