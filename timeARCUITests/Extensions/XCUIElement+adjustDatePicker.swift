//
//  XCTestCase+adjustDatePicker.swift
//  timeARCUITests
//
//  Created by d4Rk on 20.03.21.
//

import XCTest

extension XCUIElement {
    // https://stackoverflow.com/a/64507759/2019384
    @discardableResult func adjust(to newValue: String) -> Bool {
        let x = self.frame.width / 2.0
        let y = self.frame.height / 2.0
        // each self notch is about 30px high, so tapping y - 30 rotates up. y + 30 rotates down.
        var offset: CGFloat = -30.0
        var reversed = false
        let previousValue = self.value as? String
        while self.value as? String != newValue {
            self.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: x, dy: y + offset)).tap()
            usleep(250_000)
            if previousValue == self.value as? String {
                if reversed {
                    // we already tried reversing, can't find the desired value
                    break
                }
                // we didn't move the self. try reversing direction
                offset = 30.0
                reversed = true
            }
        }

        return self.value as? String == newValue
    }
}
