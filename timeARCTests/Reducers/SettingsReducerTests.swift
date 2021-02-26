//
//  TimerReducerTests.swift
//  Tests iOS
//
//  Created by d4Rk on 20.07.20.
//

import XCTest
@testable import timeARC

class SettingsReducerTests: XCTestCase {
    func testUpdateWorkingWeekDays() throws {
        var state = SettingsState()
        XCTAssertEqual(state.workingWeekDays, [.monday, .tuesday, .wednesday, .thursday, .friday])

        let action = UpdateWorkingWeekDays(workingWeekDays: [.saturday])
        state = settingsReducer(state: state, action: action)

        XCTAssertEqual(state.workingWeekDays, [.saturday])
    }

    func testUpdateWorkingDuration() throws {
        var state = SettingsState()
        XCTAssertEqual(state.workingDuration, 28800)

        let action = UpdateWorkingDuration(workingDuration: 1337)
        state = settingsReducer(state: state, action: action)

        XCTAssertEqual(state.workingDuration, 1337)
    }

    func testUpdateAccentColor() throws {
        var state = SettingsState()
        XCTAssertEqual(state.accentColor, .green)

        let action = UpdateAccentColor(color: .pink, colorScheme: .light)
        state = settingsReducer(state: state, action: action)

        XCTAssertEqual(state.accentColor, .pink)
    }
}
