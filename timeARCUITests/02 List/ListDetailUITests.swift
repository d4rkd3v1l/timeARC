//
//  ListDetailUITests.swift
//  timeARCUITests
//
//  Created by d4Rk on 21.03.21.
//

import XCTest

class ListDetailUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        self.app = self.createApp(launchArguments: ["--MockData"])

        let listTab = self.app.tabBars.buttons.element(boundBy: 1)
        listTab.tap()

        self.app.buttons["List.day.2021-03-21"].tap()
    }

    func testDetailView() throws {
        let title: String = try .localized(en: "Sun, Mar 21",
                                           de: "So. 21. März")

        XCTAssertTrue(self.app.staticTexts[title].exists)

        let start: String = try .localized(en: "8:00 AM",
                                           de: "08:00")

        let end: String = try .localized(en: "10:00 AM",
                                         de: "10:00")

        let duration = "02:00"

        XCTAssertEqual(self.app.staticTexts["ArcViewAverage.value"].label, duration)
        XCTAssertEqual(self.app.staticTexts["ArcViewAverage.start"].label, start)
        XCTAssertEqual(self.app.staticTexts["ArcViewAverage.end"].label, end)

        let timePickerLabel: String = try .localized(en: "Time Picker",
                                                     de: "Zeitauswahl")

        let startPicker = self.app.otherElements.matching(identifier: timePickerLabel).element(boundBy: 0)
        let startValue = try XCTUnwrap(startPicker.value as? String)
        XCTAssertEqual(String(startValue.prefix(start.count)), start)

        let endPicker = self.app.otherElements.matching(identifier: timePickerLabel).element(boundBy: 1)
        let endValue = try XCTUnwrap(endPicker.value as? String)
        XCTAssertEqual(String(endValue.prefix(end.count)), end)

        XCTAssertEqual(self.app.staticTexts["ListDetailRowTimeEntry.duration"].label, duration)
    }

    func testUpdateTimeEntry() throws {
        self.app.datePickers["ListDetailRowTimeEntry.start"].tap()
        try self.app.selectTime(hours: 7, minutes: 30)
        XCTAssertEqual(self.app.staticTexts["ListDetailRowTimeEntry.duration"].label, "02:30")

        self.app.datePickers["ListDetailRowTimeEntry.end"].tap()
        try self.app.selectTime(hours: 10, minutes: 30)
        XCTAssertEqual(self.app.staticTexts["ListDetailRowTimeEntry.duration"].label, "03:00")
    }

    func testDeleteTimeEntry() throws {
        self.app.staticTexts["ListDetailRowTimeEntry.duration"].swipeLeft()

        let delete: String = try .localized(en: "Delete",
                                            de: "Löschen")

        self.app.buttons[delete].tap()

        // Note: Check to be on empty list page
        let title = self.localizedString("list")
        XCTAssertTrue(self.app.staticTexts[title].exists)

        XCTAssertEqual(self.app.staticTexts["List.noEntriesYet"].label, self.localizedString("noEntriesYet"))
    }

    func testUpdateAbsenceEntry() throws {
        throw XCTSkip("Implement!!!")
    }

    func testDeleteAbsenceEntry() throws {
        throw XCTSkip("Implement!!!")
    }
}
