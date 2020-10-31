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
    let workingDays = stride(from: state.selectedStartDate.startOfDay,
                             through: state.selectedEndDate.endOfDay,
                             by: 86400)
        .filter {
            let weekday = Calendar.current.component(.weekday, from: $0)
            return appState.settingsState.workingWeekDays.contains(WeekDay(weekday))
        }
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

    state.averageDuration = workingDays
        .compactMap { relevantTimeEntries[$0]?.totalDurationInSeconds }
        .average()

    state.averageWorkingHoursStartDate = relevantTimeEntries
        .compactMap { _, timeEntries in
            timeEntries.first?.start
        }
        .averageTime

    state.averageWorkingHoursEndDate = relevantTimeEntries
        .compactMap { _, timeEntries in
            timeEntries.last?.end
        }
        .averageTime

    let totalBreaksInSeconds = workingDays
        .compactMap { relevantTimeEntries[$0]?.totalBreaksInSeconds }

    state.averageBreaksDuration = totalBreaksInSeconds.average()

    state.averageOvertimeDuration = state.averageDuration - (appState.settingsState.workingMinutesPerDay * 60)

    state.totalDays = workingDays.count

    state.totalDaysWorked = relevantTimeEntries.count

    state.totalDuration = workingDays
        .map { day -> Int in
            let actualWorkingDuration = (relevantTimeEntries[day]?.totalDurationInSeconds ?? 0)
            let absenceDuration = relevantAbsenceEntries.totalDurationInSeconds(for: day, with: appState.settingsState.workingMinutesPerDay)
            return actualWorkingDuration + absenceDuration
        }
        .sum()


    state.totalBreaksDuration = totalBreaksInSeconds.sum()

    state.totalOvertimeDuration = state.totalDuration - (appState.settingsState.workingMinutesPerDay * 60) * workingDays.count


    
    var absenceEntriesByDay: [Day: [AbsenceEntry]] = [:]
    workingDays.forEach { day in
        absenceEntriesByDay[day] = relevantAbsenceEntries.absenceEntries(for: day)
    }

//    state.totalAbsenceDuration = Float(absenceEntriesByDay.reduce(0) { total, current in
//        total + Int((current.value.map { $0.type.offPercentage }.max() ?? 1) * Float(appState.settingsState.workingMinutesPerDay * 60))
//    })
}
