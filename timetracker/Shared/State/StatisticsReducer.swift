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

        ensureStatistics(&state, with: appState)

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

        ensureStatistics(&state, with: appState)

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

        ensureStatistics(&state, with: appState)

    case _ as StatisticsRefresh: // TODO: TBD if we just update the stats everytime?
        ensureStatistics(&state, with: appState)

    default:
        break
    }

    return state
}

private func ensureStatistics(_ state: inout StatisticsState, with appState: AppState) {
    switch state.selectedTimeFrame {
    case .week:
        state.selectedDateText = "\(state.selectedStartDate.formatted("dd.MM.")) - \(state.selectedEndDate.formatted("dd.MM.yyyy")) (\(Calendar.current.component(.weekOfYear, from: state.selectedStartDate)))"

    case .month:
        state.selectedDateText = state.selectedStartDate.formatted("MMMM yyyy")

    case .year:
        state.selectedDateText = state.selectedStartDate.formatted("yyyy")

    case .allTime:
        state.selectedDateText = "\(state.selectedStartDate.formatted("dd.MM.yyyy")) - \(state.selectedEndDate.formatted("dd.MM.yyyy"))"
    }

    let range = (state.selectedStartDate.startOfDay...state.selectedEndDate.endOfDay)
    let days = stride(from: state.selectedStartDate.startOfDay,
                             through: state.selectedEndDate.endOfDay,
                             by: 86400)
        .map { $0.day }

    let relevantTimeEntries = appState.timeState.timeEntries.filter {
        range.contains($0.key.date)
    }

    let relevantAbsenceEntries = appState.timeState.absenceEntries.exactAbsenceEntries(for: range)

    guard !(relevantTimeEntries.isEmpty && relevantAbsenceEntries.isEmpty) else {
        state.errorMessage = "noStatisticsForTimeFrameMessage"
        return
    }

    state.errorMessage = nil
    state.targetDuration = appState.settingsState.workingMinutesPerDay * 60

    let totalDurationInSeconds = days
        .map { day -> Int in
            let actualWorkingDuration = (relevantTimeEntries[day]?.totalDurationInSeconds ?? 0)
            let absenceDuration = relevantAbsenceEntries.totalDurationInSeconds(for: day, with: appState.settingsState.workingMinutesPerDay)
            return actualWorkingDuration + absenceDuration
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

    let totalOvertimeInSeconds = days
        .map { day -> Int in
            let isCurrentDayAWorkingDay = appState.settingsState.workingWeekDays.contains(WeekDay(Calendar.current.component(.weekday, from: day.date)))
            let actualWorkingDuration = (relevantTimeEntries[day]?.totalDurationInSeconds ?? 0)
            let absenceDuration = relevantAbsenceEntries.totalDurationInSeconds(for: day, with: appState.settingsState.workingMinutesPerDay)
            let expectedWorkingDuration = isCurrentDayAWorkingDay ? (appState.settingsState.workingMinutesPerDay * 60) : 0
            return actualWorkingDuration + absenceDuration - expectedWorkingDuration
        }

    state.averageOvertimeDuration = totalOvertimeInSeconds.average()
    state.totalOvertimeDuration = totalOvertimeInSeconds.sum()

    state.totalDays = days
        .reduce(0) { result, current in
            let isCurrentDayAWorkingDay = appState.settingsState.workingWeekDays.contains(WeekDay(Calendar.current.component(.weekday, from: current.date)))
            return result + (isCurrentDayAWorkingDay ? 1 : 0)
        }
    state.totalDaysWorked = relevantTimeEntries.count

    var absenceEntriesByDay: [Day: [AbsenceEntry]] = [:]
    days.forEach { day in
        absenceEntriesByDay[day] = relevantAbsenceEntries.absenceEntries(for: day)
    }

    state.totalAbsenceDuration = absenceEntriesByDay.reduce(0) { total, current in
        total + Int((current.value.map { $0.type.offPercentage }.max() ?? 1) * Float(appState.settingsState.workingMinutesPerDay * 60))
    }
}
