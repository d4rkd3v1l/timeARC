//
//  XCUIApplication+type.swift
//  timeARCUITests
//
//  Created by d4Rk on 20.03.21.
//

import XCTest

extension XCUIApplication {
    func typeOnKeyboard(text: String) {
        text.forEach { char in
            self.keyboards.keys[String(char)].tap()
        }
    }
}
