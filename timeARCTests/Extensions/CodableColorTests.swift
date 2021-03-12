//
//  CodableColorTests.swift
//  timeARCTests
//
//  Created by d4Rk on 04.10.20.
//

import XCTest
@testable import timeARC

class CodableColorTests: XCTestCase {
    func testInit() throws {
        XCTAssertEqual(CodableColor(.black), CodableColor.black)
        XCTAssertEqual(CodableColor(.blue), CodableColor.blue)
        XCTAssertEqual(CodableColor(.gray), CodableColor.gray)
        XCTAssertEqual(CodableColor(.green), CodableColor.green)
        XCTAssertEqual(CodableColor(.orange), CodableColor.orange)
        XCTAssertEqual(CodableColor(.pink), CodableColor.pink)
        XCTAssertEqual(CodableColor(.primary), CodableColor.primary)
        XCTAssertEqual(CodableColor(.purple), CodableColor.purple)
        XCTAssertEqual(CodableColor(.red), CodableColor.red)
        XCTAssertEqual(CodableColor(.white), CodableColor.white)
        XCTAssertEqual(CodableColor(.yellow), CodableColor.yellow)
    }

    func testColor() throws {
        XCTAssertEqual(CodableColor.black.color, .black)
        XCTAssertEqual(CodableColor.blue.color, .blue)
        XCTAssertEqual(CodableColor.gray.color, .gray)
        XCTAssertEqual(CodableColor.green.color, .green)
        XCTAssertEqual(CodableColor.orange.color, .orange)
        XCTAssertEqual(CodableColor.pink.color, .pink)
        XCTAssertEqual(CodableColor.primary.color, .primary)
        XCTAssertEqual(CodableColor.purple.color, .purple)
        XCTAssertEqual(CodableColor.red.color, .red)
        XCTAssertEqual(CodableColor.white.color, .white)
        XCTAssertEqual(CodableColor.yellow.color, .yellow)
    }

    func testContrastColor() throws {
        XCTAssertEqual(CodableColor.black.contrastColor(for: .light), .white)
        XCTAssertEqual(CodableColor.black.contrastColor(for: .dark), .white)
        XCTAssertEqual(CodableColor.blue.contrastColor(for: .light), .white)
        XCTAssertEqual(CodableColor.blue.contrastColor(for: .dark), .white)
        XCTAssertEqual(CodableColor.gray.contrastColor(for: .light), .black)
        XCTAssertEqual(CodableColor.gray.contrastColor(for: .dark), .black)
        XCTAssertEqual(CodableColor.green.contrastColor(for: .light), .black)
        XCTAssertEqual(CodableColor.green.contrastColor(for: .dark), .black)
        XCTAssertEqual(CodableColor.orange.contrastColor(for: .light), .black)
        XCTAssertEqual(CodableColor.orange.contrastColor(for: .dark), .black)
        XCTAssertEqual(CodableColor.pink.contrastColor(for: .light), .black)
        XCTAssertEqual(CodableColor.pink.contrastColor(for: .dark), .black)
        XCTAssertEqual(CodableColor.primary.contrastColor(for: .light), .white)
        XCTAssertEqual(CodableColor.primary.contrastColor(for: .dark), .black)
        XCTAssertEqual(CodableColor.purple.contrastColor(for: .light), .white)
        XCTAssertEqual(CodableColor.purple.contrastColor(for: .dark), .white)
        XCTAssertEqual(CodableColor.red.contrastColor(for: .light), .black)
        XCTAssertEqual(CodableColor.red.contrastColor(for: .dark), .black)
        XCTAssertEqual(CodableColor.white.contrastColor(for: .light), .black)
        XCTAssertEqual(CodableColor.white.contrastColor(for: .dark), .black)
        XCTAssertEqual(CodableColor.yellow.contrastColor(for: .light), .black)
        XCTAssertEqual(CodableColor.yellow.contrastColor(for: .dark), .black)
    }
}
