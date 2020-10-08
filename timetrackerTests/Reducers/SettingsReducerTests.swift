//
//  TimerReducerTests.swift
//  Tests iOS
//
//  Created by d4Rk on 20.07.20.
//

import XCTest
@testable import timetracker

class SettingsReducerTests: XCTestCase {
    func testUpdateWorkingWeekDays() throws {
        var state = SettingsState()
        XCTAssertEqual(state.workingWeekDays, [.monday, .tuesday, .wednesday, .thursday, .friday])

        let action = UpdateWorkingWeekDays(workingWeekDays: [.saturday])
        state = settingsReducer(state: state, action: action)

        XCTAssertEqual(state.workingWeekDays, [.saturday])
    }

    func testUpdateWorkingMinutesPerDay() throws {
        var state = SettingsState()
        XCTAssertEqual(state.workingMinutesPerDay, 480)

        let action = UpdateWorkingMinutesPerDay(workingMinutesPerDay: 42)
        state = settingsReducer(state: state, action: action)

        XCTAssertEqual(state.workingMinutesPerDay, 42)
    }

    func testUpdateAccentColor() throws {
        var state = SettingsState()
        XCTAssertEqual(state.accentColor, .green)

        let action = UpdateAccentColor(color: .pink)
        state = settingsReducer(state: state, action: action)

        XCTAssertEqual(state.accentColor, .pink)
    }
}
