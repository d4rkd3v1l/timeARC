//
//  SettingsUITests.swift
//  timeARCUITests
//
//  Created by d4Rk on 21.03.21.
//

import XCTest

class SettingsUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        self.app = self.createApp()

        let settingsTab = self.app.tabBars.buttons.element(boundBy: 3)
        settingsTab.tap()
    }

    func testTitle() throws {
        let title = self.localizedString("settings")
        XCTAssertTrue(self.app.staticTexts[title].exists)
    }

    func testWorkingHours() throws {
        XCTAssertEqual(self.app.staticTexts["Settings.workingHoursLabel"].label, self.localizedString("workingHours"))

        let time: String = try .localized(en: "Time",
                                          de: "Zeit")

        self.app.datePickers["Settings.workingHours"].tap()
        self.app.textFields[time].tap()
        self.app.typeOnKeyboard(text: "0730")

        let background = self.app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.5))
        background.tap()
    }

    func testWeekDays() throws {
        let weekDaysButton = self.app.buttons["Settings.weekDays"]
        let weekDays = self.localizedString("weekDays")
        XCTAssertEqual(weekDaysButton.label, "\(weekDays), 5")

        weekDaysButton.tap()

        for weekdaySymbol in Calendar.current.weekdaySymbols {
            XCTAssertTrue(self.app.buttons[weekdaySymbol].exists)
        }

        let friday = Calendar.current.weekdaySymbols[5]
        self.app.buttons[friday].tap()

        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        backButton.tap()

        XCTAssertEqual(weekDaysButton.label, "\(weekDays), 4")
    }

    func testAccentColor() throws {
        XCTAssertEqual(self.app.staticTexts["Settings.accentColorLabel"].label, self.localizedString("accentColor"))

        XCTAssertTrue(self.app.buttons["primary"].exists)
        XCTAssertTrue(self.app.buttons["blue"].exists)
        XCTAssertTrue(self.app.buttons["gray"].exists)
        XCTAssertTrue(self.app.buttons["green"].exists)
        XCTAssertTrue(self.app.buttons["orange"].exists)
        XCTAssertTrue(self.app.buttons["pink"].exists)
        XCTAssertTrue(self.app.buttons["purple"].exists)
        XCTAssertTrue(self.app.buttons["red"].exists)
        XCTAssertTrue(self.app.buttons["yellow"].exists)
        
        let selected: String = try .localized(en: "selected",
                                              de: "ausgewählt")

        XCTAssertEqual(self.app.buttons["green"].label, selected)
        
        self.app.buttons["pink"].tap()

        XCTAssertTrue(self.app.alerts.element(boundBy: 0).exists)
        self.app.alerts.element(boundBy: 0).buttons["OK"].tap()

        XCTAssertEqual(self.app.buttons["pink"].label, selected)
    }
}
 
