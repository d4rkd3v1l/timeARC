//
//  Collection+averageTests.swift
//  timetrackerTests
//
//  Created by d4Rk on 04.10.20.
//

import XCTest
@testable import timeARC

class CollectionAverageTests: XCTestCase {
    func testSum() throws {
        let sequence = [1, 5, 2]
        XCTAssertEqual(sequence.sum(), 8)
    }

    func testAverage_Int() throws {
        let sequence = [1, 5, 2]
        XCTAssertEqual(sequence.average(), 2.67, accuracy: 0.01)
    }

    func testAverage_Int_Empty() throws {
        let sequence: [Int] = []
        XCTAssertEqual(sequence.average(), .zero)
    }

    func testAverage_Float() throws {
        let sequence = [1.2, 4.6, 3.234]
        XCTAssertEqual(sequence.average(), 3.01, accuracy: 0.01)
    }

    func testAverage_Float_Empty() throws {
        let sequence: [Float] = []
        XCTAssertEqual(sequence.average(), .zero)
    }
}
