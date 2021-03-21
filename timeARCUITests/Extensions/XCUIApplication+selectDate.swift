//
//  XCUIApplication+selectDate.swift
//  timeARCUITests
//
//  Created by d4Rk on 21.03.21.
//

import XCTest

extension XCUIApplication {
    func selectDate(year: Int, month: Int, day: Int, dismissAutomatically: Bool = true) throws {
        let monthLabel: String = try .localized(en: "Month",
                                                de: "Monat")

        self.buttons[monthLabel].tap()

        let yearPicker = self.pickerWheels.element(boundBy: 1)
        yearPicker.adjust(to: String(year))

        let monthPicker = self.pickerWheels.element(boundBy: 0)
        monthPicker.adjust(to: DateFormatter().monthSymbols[month - 1])

        self.buttons[monthLabel].tap()

        self.buttons
            .matching(NSPredicate(format: "label CONTAINS '\(day)'"))
            .element(boundBy: 0)
            .tap()

        if dismissAutomatically {
            let background = self.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.5))
            background.tap()
        }
    }

    func selectTime(hours: Int, minutes: Int, dismissAutomatically: Bool = true) throws {
        let time: String = try .localized(en: "Time",
                                          de: "Zeit")

        self.textFields[time].tap()
        self.typeOnKeyboard(text: "\(String(format: "%02d", hours) + String(format: "%02d", minutes))")

        let background = self.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.5))
        background.tap()

        if dismissAutomatically {
            let background = self.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.5))
            background.tap()
        }
    }
}
