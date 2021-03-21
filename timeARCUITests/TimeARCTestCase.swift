//
//  TimeArcUITestCase.swift
//  timeARCUITests
//
//  Created by d4Rk on 19.03.21.
//

import XCTest

class TimeARCTestCase: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        self.continueAfterFailure = false

        self.app = XCUIApplication()
        self.app.launchArguments = ["--UITests"]
        self.app.launch()
    }
}
