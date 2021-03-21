//
//  ListUITests.swift
//  timeARCUITests
//
//  Created by d4Rk on 19.03.21.
//

import XCTest

class ListUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        self.app = self.createApp()

        let listTab = self.app.tabBars.buttons.element(boundBy: 1)
        listTab.tap()
    }

    func testEmpty() throws {
        let title = self.localizedString("list")
        XCTAssertTrue(self.app.staticTexts[title].exists)

        XCTAssertEqual(self.app.staticTexts["List.noEntriesYet"].label, self.localizedString("noEntriesYet"))
    }

    func testCreateTimeEntry() throws {
        self.app.buttons["ToolbarAddEntry.add"].tap()

        let timeEntry = self.localizedString("timeEntry")
        self.app.buttons[timeEntry].tap()

        let title = self.localizedString("createTimeEntryTitle")
        XCTAssertTrue(self.app.staticTexts[title].exists)

        // Select date
        XCTAssertEqual(self.app.staticTexts["ListTimeEntryCreate.dateLabel"].label, self.localizedString("date"))

        self.app.datePickers["ListTimeEntryCreate.date"].tap()
        try self.app.selectDate(year: 2020, month: 7, day: 25)

        // Select time
        XCTAssertEqual(self.app.staticTexts["ListTimeEntryCreate.timeLabel"].label, self.localizedString("time"))

        let background = self.app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.5))

        let time: String = try .localized(en: "Time",
                                          de: "Zeit")

        self.app.datePickers["ListTimeEntryCreate.start"].tap()
        self.app.textFields[time].tap()
        self.app.typeOnKeyboard(text: "1013")
        background.tap()

        self.app.datePickers["ListTimeEntryCreate.end"].tap()
        self.app.textFields[time].tap()
        self.app.typeOnKeyboard(text: "1037")
        background.tap()

        self.app.buttons["ListTimeEntryCreate.add"].tap()

        let entry: String = try .localized(en: "Sat, 07/25, 00:24",
                                           de: "Sa, 25.07., 00:24")
        XCTAssertTrue(self.app.buttons[entry].exists)
    }

    func testCreateAbsenceEntry() throws {
        self.app.buttons["ToolbarAddEntry.add"].tap()

        let timeEntry = self.localizedString("absenceEntry")
        self.app.buttons[timeEntry].tap()

        let title = self.localizedString("createAbsenceEntryTitle")
        XCTAssertTrue(self.app.staticTexts[title].exists)

        // Select absence type
        self.app.buttons["ListAbsenceEntryCreate.type"].tap()
        self.app.buttons["ListAbsenceEntryCreate.type.holiday"].tap()

        let selectedAbsenceType = try XCTUnwrap(self.app.buttons["ListAbsenceEntryCreate.type"].value as? String)
        XCTAssertEqual(selectedAbsenceType, try .localized(en: "🏝 Holiday",
                                                           de: "🏝 Urlaub"))

        // Select dates
        self.app.datePickers["ListAbsenceEntryCreate.start"].tap()
        try self.app.selectDate(year: 2020, month: 07, day: 25)

        self.app.datePickers["ListAbsenceEntryCreate.end"].tap()
        try self.app.selectDate(year: 2020, month: 07, day: 29)

        self.app.buttons["ListAbsenceEntryCreate.add"].tap()

        let entry: String = try .localized(en: "Sat, 07/25, 00:00",
                                           de: "Sa, 25.07., 00:00")
        XCTAssertTrue(self.app.buttons[entry].exists)
    }
}
