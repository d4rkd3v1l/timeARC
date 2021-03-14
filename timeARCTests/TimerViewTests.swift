//
//  TimerViewTests.swift
//  timeARCTests
//
//  Created by d4Rk on 13.03.21.
//

import XCTest
import ViewInspector
import SwiftUIFlux
@testable import timeARC

extension StoreConnector: Inspectable {}
extension TimerView: Inspectable {}

class TimerViewTests: XCTestCase {
    func testBla() throws {
        var sut = TimerView()
        
        let exp = sut.on(\.didAppear) { view in
            try view.find(button: "start")
        }
        ViewHosting.host(view: sut.environmentObject(testStore))
        wait(for: [exp], timeout: 0.5)
    }
}
