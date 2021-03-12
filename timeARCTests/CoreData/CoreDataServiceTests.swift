//
//  CoreDataServiceTests.swift
//  timeARCTests
//
//  Created by d4Rk on 12.03.21.
//

import XCTest
import SwiftUIFlux
import Resolver
import CoreData
@testable import timeARC

class CoreDataServiceTests: XCTestCase {
    @LazyInjected private var coreDataService: CoreDataService

    func testLoadAppState() throws {
        let appState = try self.coreDataService.loadAppState()

        XCTAssertEqual(appState.isAppStateLoading, false)
    }
}
