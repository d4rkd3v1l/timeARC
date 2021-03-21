//
//  timeARCUITests.swift
//  timeARCUITests
//
//  Created by d4Rk on 03.10.20.
//

import XCTest

class TimerUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        self.app = self.createApp()
    }

    func testArcView() throws {
        XCTAssertEqual(self.app.staticTexts["ArcViewFull.value"].label, "0")
        XCTAssertEqual(self.app.staticTexts["ArcViewFull.percentage"].label, "%")
        XCTAssertEqual(self.app.staticTexts["ArcViewFull.timer"].label, "00:00:00")

        self.app.staticTexts["ArcViewFull.timer"].tap()
        XCTAssertEqual(self.app.staticTexts["ArcViewFull.timer"].label, "-08:00:00")
    }

    func testTimerButton() throws {
        let timerButton = self.app.buttons["Timer.timer"]
        XCTAssertEqual(timerButton.label, self.localizedString("start"))

        timerButton.tap()
        XCTAssertEqual(timerButton.label, self.localizedString("stop"))


        timerButton.tap()
        XCTAssertEqual(timerButton.label, self.localizedString("start"))
    }

    func testTodayWeekSwipe() throws {
        let today = self.localizedString("today")
        XCTAssertTrue(self.app.staticTexts[today].exists)

        self.app.staticTexts["ArcViewFull.value"].swipeLeft()

        let week = self.localizedString("week")
        XCTAssertTrue(self.app.staticTexts[week].exists)
    }
}
