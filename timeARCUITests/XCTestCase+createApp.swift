//
//  TimeArcUITestCase.swift
//  timeARCUITests
//
//  Created by d4Rk on 19.03.21.
//

import XCTest

extension XCTestCase {
    func createApp(launchArguments: [String] = []) -> XCUIApplication {
        self.continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--UITests"]
        app.launchArguments.append(contentsOf: launchArguments)
        app.launch()
        return app
    }
}
