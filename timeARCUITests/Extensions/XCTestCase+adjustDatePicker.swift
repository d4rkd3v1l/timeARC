//
//  XCTestCase+adjustDatePicker.swift
//  timeARCUITests
//
//  Created by d4Rk on 20.03.21.
//

import XCTest

extension XCTestCase {
    // https://stackoverflow.com/a/64507759/2019384
    @discardableResult func adjust(picker: XCUIElement, to newValue: String) -> Bool {
        let x = picker.frame.width / 2.0
        let y = picker.frame.height / 2.0
        // each self notch is about 30px high, so tapping y - 30 rotates up. y + 30 rotates down.
        var offset: CGFloat = -30.0
        var reversed = false
        let previousValue = picker.value as? String
        while picker.value as? String != newValue {
            picker.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: x, dy: y + offset)).tap()
            let briefWait = self.expectation(description: "Wait for self to rotate")
            briefWait.isInverted = true
            self.wait(for: [briefWait], timeout: 0.25)
            if previousValue == picker.value as? String {
                if reversed {
                    // we already tried reversing, can't find the desired value
                    break
                }
                // we didn't move the self. try reversing direction
                offset = 30.0
                reversed = true
            }
        }

        return picker.value as? String == newValue
    }
}
