//
//  TestHelpers.swift
//  timeARCTests
//
//  Created by d4Rk on 30.10.20.
//

import Foundation
import XCTest

extension Date {
    init(year: Int, month: Int, day: Int) throws {
        let dateComponents = DateComponents(year: year, month: month, day: day)
        self = try XCTUnwrap(Calendar.current.date(from: dateComponents))
    }

    init(hour: Int, minute: Int, second: Int) throws {
        let dateComponents = DateComponents(hour: hour, minute: minute, second: second)
        self = try XCTUnwrap(Calendar.current.date(from: dateComponents))
    }

    init(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) throws {
        let dateComponents = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        self = try XCTUnwrap(Calendar.current.date(from: dateComponents))
    }
}
