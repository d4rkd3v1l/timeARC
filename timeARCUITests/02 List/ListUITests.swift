//
//  ListUITests.swift
//  timeARCUITests
//
//  Created by d4Rk on 19.03.21.
//

import XCTest

class ListUITests: TimeARCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        self.app.tabBars.buttons.element(boundBy: 1).tap()
    }

    func testEmpty() throws {
        let title = self.localizedString("list")
        XCTAssertTrue(self.app.staticTexts[title].exists)

        XCTAssertEqual(self.app.staticTexts["List.noEntriesYet"].label, self.localizedString("noEntriesYet"))
    }

    func testAddTimeEntry() throws {
        self.app.buttons["ToolbarAddEntry.add"].tap()

        let timeEntry = self.localizedString("timeEntry")
        self.app.buttons[timeEntry].tap()

        let title = self.localizedString("createTimeEntryTitle")
        XCTAssertTrue(self.app.staticTexts[title].exists)

        // Select date
        let picker = self.app.datePickers["ListTimeEntryCreate.date"]
        try self.select(year: 2020, month: 7, day: 25, picker: picker)

        // Select time
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

    func testAddAbsenceEntry() throws {
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
        let startPicker = self.app.datePickers["ListAbsenceEntryCreate.start"]
        try self.select(year: 2020, month: 07, day: 25, picker: startPicker)

        let endPicker = self.app.datePickers["ListAbsenceEntryCreate.end"]
        try self.select(year: 2020, month: 07, day: 29, picker: endPicker)

        self.app.buttons["ListAbsenceEntryCreate.add"].tap()

        let entry: String = try .localized(en: "Sat, 07/25, 00:00",
                                           de: "Sa, 25.07., 00:00")
        XCTAssertTrue(self.app.buttons[entry].exists)
    }

    // MARK: - Helper

    private func select(year: Int, month: Int, day: Int, picker: XCUIElement) throws {
        let monthLabel: String = try .localized(en: "Month",
                                                de: "Monat")

        picker.tap()
        self.app.buttons[monthLabel].tap()

        let yearPicker = self.app.pickerWheels.element(boundBy: 1)
        self.adjust(picker: yearPicker, to: String(year))

        let monthPicker = self.app.pickerWheels.element(boundBy: 0)
        self.adjust(picker: monthPicker, to: DateFormatter().monthSymbols[month - 1])

        self.app.buttons[monthLabel].tap()

        self.app.buttons
            .matching(NSPredicate(format: "label CONTAINS '\(day)'"))
            .element(boundBy: 0)
            .tap()

        let background = self.app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.5))
        background.tap()
    }
}
