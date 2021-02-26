//
//  StatisticsReducerTests.swift
//  timeARCTests
//
//  Created by d4Rk on 04.10.20.
//

import XCTest
@testable import timeARC

class StatisticsReducerTests: XCTestCase {
    var startDate: Date!
    var endDate: Date!

    override func setUpWithError() throws {
        self.startDate = try Date(year: 2020, month: 10, day: 28)
        self.endDate = try Date(year: 2020, month: 10, day: 30)
    }

    // MARK: - Change Time Frame

    func testChangeTimeFrame_week() throws {
        let appState = AppState()

        let action = StatisticsChangeTimeFrame(timeFrame: .week)
        let state = statisticsReducer(appState: appState, action: action)

        XCTAssertEqual(state.selectedStartDate, Date().firstOfWeek)
        XCTAssertEqual(state.selectedEndDate, Date().lastOfWeek)
    }

    func testChangeTimeFrame_month() throws {
        let appState = AppState()

        let action = StatisticsChangeTimeFrame(timeFrame: .month)
        let state = statisticsReducer(appState: appState, action: action)

        XCTAssertEqual(state.selectedStartDate, Date().firstOfMonth)
        XCTAssertEqual(state.selectedEndDate, Date().lastOfMonth)
    }

    func testChangeTimeFrame_year() throws {
        let appState = AppState()

        let action = StatisticsChangeTimeFrame(timeFrame: .year)
        let state = statisticsReducer(appState: appState, action: action)

        XCTAssertEqual(state.selectedStartDate, Date().firstOfYear)
        XCTAssertEqual(state.selectedEndDate, Date().lastOfYear)
    }

    func testChangeTimeFrame_allTime() throws {
        var appState = AppState()

        let startDate1 = try Date(year: 2019, month: 7, day: 20, hour: 8, minute: 0, second: 0)
        let endDate1 = try Date(year: 2019, month: 7, day: 20, hour: 12, minute: 0, second: 0)

        let startDate2 = try Date(year: 2020, month: 10, day: 30, hour: 11, minute: 0, second: 0)
        let endDate2 = try Date(year: 2020, month: 10, day: 30, hour: 15, minute: 0, second: 0)

        let timeEntry1 = TimeEntry(start: startDate1, end: endDate1)
        let timeEntry2 = TimeEntry(start: startDate2, end: endDate2)

        appState.timeState.timeEntries = [startDate1.day: [timeEntry1],
                                          startDate2.day: [timeEntry2]]

        let action = StatisticsChangeTimeFrame(timeFrame: .allTime)
        let state = statisticsReducer(appState: appState, action: action)

        XCTAssertEqual(state.selectedStartDate, startDate1.startOfDay)
        XCTAssertEqual(state.selectedEndDate, endDate2.startOfDay)
    }

    // MARK: - Next Interval

    func testNextInterval_week() throws {
        var appState = AppState()
        appState.statisticsState.selectedTimeFrame = .week
        appState.statisticsState.selectedStartDate = self.startDate
        appState.statisticsState.selectedEndDate = self.endDate

        let action = StatisticsNextInterval()
        let state = statisticsReducer(appState: appState, action: action)

        if Locale.current.identifier == "de_DE" {
            XCTAssertEqual(state.selectedStartDate, try Date(year: 2020, month: 11, day: 2))
            XCTAssertEqual(state.selectedEndDate, try Date(year: 2020, month: 11, day: 8))
        } else if Locale.current.identifier == "en_US" {
            XCTAssertEqual(state.selectedStartDate, try Date(year: 2020, month: 11, day: 1))
            XCTAssertEqual(state.selectedEndDate, try Date(year: 2020, month: 11, day: 7))
        } else {
            throw XCTSkip("Invalid locale for this test.")
        }
    }

    func testNextInterval_month() throws {
        var appState = AppState()
        appState.statisticsState.selectedTimeFrame = .month
        appState.statisticsState.selectedStartDate = self.startDate
        appState.statisticsState.selectedEndDate = self.endDate

        let action = StatisticsNextInterval()
        let state = statisticsReducer(appState: appState, action: action)

        XCTAssertEqual(state.selectedStartDate, try Date(year: 2020, month: 11, day: 1))
        XCTAssertEqual(state.selectedEndDate, try Date(year: 2020, month: 11, day: 30))
    }

    func testNextInterval_year() throws {
        var appState = AppState()
        appState.statisticsState.selectedTimeFrame = .year
        appState.statisticsState.selectedStartDate = self.startDate
        appState.statisticsState.selectedEndDate = self.endDate

        let action = StatisticsNextInterval()
        let state = statisticsReducer(appState: appState, action: action)

        XCTAssertEqual(state.selectedStartDate, try Date(year: 2021, month: 1, day: 1))
        XCTAssertEqual(state.selectedEndDate, try Date(year: 2021, month: 12, day: 31))
    }

    func testNextInterval_allTime() throws {
        var appState = AppState()
        appState.statisticsState.selectedTimeFrame = .allTime
        appState.statisticsState.selectedStartDate = self.startDate
        appState.statisticsState.selectedEndDate = self.endDate

        let action = StatisticsNextInterval()
        let state = statisticsReducer(appState: appState, action: action)

        XCTAssertEqual(state.selectedStartDate, self.startDate)
        XCTAssertEqual(state.selectedEndDate, self.endDate)
    }

    // MARK: - Previous Interval

    func testPreviousInterval_week() throws {
        var appState = AppState()
        appState.statisticsState.selectedTimeFrame = .week
        appState.statisticsState.selectedStartDate = self.startDate
        appState.statisticsState.selectedEndDate = self.endDate

        let action = StatisticsPreviousInterval()
        let state = statisticsReducer(appState: appState, action: action)

        if Locale.current.identifier == "de_DE" {
            XCTAssertEqual(state.selectedStartDate, try Date(year: 2020, month: 10, day: 19))
            XCTAssertEqual(state.selectedEndDate, try Date(year: 2020, month: 10, day: 25))
        } else if Locale.current.identifier == "en_US" {
            XCTAssertEqual(state.selectedStartDate, try Date(year: 2020, month: 10, day: 18))
            XCTAssertEqual(state.selectedEndDate, try Date(year: 2020, month: 10, day: 24))
        } else {
            throw XCTSkip("Invalid locale for this test.")
        }
    }

    func testPreviousInterval_month() throws {
        var appState = AppState()
        appState.statisticsState.selectedTimeFrame = .month
        appState.statisticsState.selectedStartDate = self.startDate
        appState.statisticsState.selectedEndDate = self.endDate

        let action = StatisticsPreviousInterval()
        let state = statisticsReducer(appState: appState, action: action)

        XCTAssertEqual(state.selectedStartDate, try Date(year: 2020, month: 9, day: 1))
        XCTAssertEqual(state.selectedEndDate, try Date(year: 2020, month: 9, day: 30))
    }

    func testPreviousInterval_year() throws {
        var appState = AppState()
        appState.statisticsState.selectedTimeFrame = .year
        appState.statisticsState.selectedStartDate = self.startDate
        appState.statisticsState.selectedEndDate = self.endDate

        let action = StatisticsPreviousInterval()
        let state = statisticsReducer(appState: appState, action: action)

        XCTAssertEqual(state.selectedStartDate, try Date(year: 2019, month: 1, day: 1))
        XCTAssertEqual(state.selectedEndDate, try Date(year: 2019, month: 12, day: 31))
    }

    func testPreviousInterval_allTime() throws {
        var appState = AppState()
        appState.statisticsState.selectedTimeFrame = .allTime
        appState.statisticsState.selectedStartDate = self.startDate
        appState.statisticsState.selectedEndDate = self.endDate

        let action = StatisticsPreviousInterval()
        let state = statisticsReducer(appState: appState, action: action)

        XCTAssertEqual(state.selectedStartDate, self.startDate)
        XCTAssertEqual(state.selectedEndDate, self.endDate)
    }
}
