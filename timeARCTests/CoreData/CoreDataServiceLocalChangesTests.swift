//
//  CoreDataTests.swift
//  timeARCTests
//
//  Created by d4Rk on 27.02.21.
//

import XCTest
import SwiftUIFlux
import Resolver
import CoreData
@testable import timeARC

class CoreDataServiceLocalChangesTests: XCTestCase {
    @LazyInjected private var coreDataService: CoreDataService
    private var initialTimeEntry: TimeEntry!
    private var initialAbsenceEntry: AbsenceEntry!

    override func setUpWithError() throws {
        let exp = expectation(description: "A local change must not trigger a dispatch.")
        exp.isInverted = true

        let dispatch: DispatchFunction = { action in
            exp.fulfill()
        }

        Resolver.registerMock()
        Resolver.register { dispatch }

        self.initialTimeEntry = TimeEntry(start: Date(), end: Date())
        try self.coreDataService.insert(timeEntry: self.initialTimeEntry)

        try self.coreDataService.insert() { (managedObject: ManagedAbsenceType) in
            managedObject.id = AbsenceType.dummy.id
            managedObject.title = AbsenceType.dummy.title
            managedObject.icon = AbsenceType.dummy.icon
            managedObject.offPercentage = AbsenceType.dummy.offPercentage
        }

        self.initialAbsenceEntry = AbsenceEntry(type: .dummy, start: Day(), end: Day())
        try self.coreDataService.insert(absenceEntry: self.initialAbsenceEntry)
    }

    func testInsertTimeEntry() throws {
        let newTimeEntry = TimeEntry(start: Date(), end: nil)

        try self.coreDataService.insert(timeEntry: newTimeEntry)

        let managedTimeEntry: ManagedTimeEntry = try self.coreDataService.fetch(id: newTimeEntry.id)
        XCTAssertEqual(managedTimeEntry.id, newTimeEntry.id)
        XCTAssertEqual(managedTimeEntry.start, newTimeEntry.start)
        XCTAssertEqual(managedTimeEntry.end, newTimeEntry.end)

        waitForExpectations(timeout: 0.2)
    }

    func testUpdateTimeEntry() throws {
        var updatedTimeEntry = self.initialTimeEntry!
        updatedTimeEntry.end = nil

        try self.coreDataService.update(timeEntry: updatedTimeEntry)

        let managedTimeEntry: ManagedTimeEntry = try self.coreDataService.fetch(id: updatedTimeEntry.id)
        XCTAssertEqual(managedTimeEntry.id, self.initialTimeEntry.id)
        XCTAssertEqual(managedTimeEntry.start, updatedTimeEntry.start)
        XCTAssertEqual(managedTimeEntry.end, updatedTimeEntry.end)

        waitForExpectations(timeout: 0.2)
    }

    func testInsertAbsenceEntry() throws {
        let newAbsenceEntry = AbsenceEntry(type: .dummy, start: Day(), end: Day())

        try self.coreDataService.insert(absenceEntry: newAbsenceEntry)

        let managedAbsenceEntry: ManagedAbsenceEntry = try self.coreDataService.fetch(id: newAbsenceEntry.id)
        XCTAssertEqual(managedAbsenceEntry.id, newAbsenceEntry.id)
        XCTAssertEqual(AbsenceType(try XCTUnwrap(managedAbsenceEntry.type)), newAbsenceEntry.type)
        XCTAssertEqual(managedAbsenceEntry.start, newAbsenceEntry.start.date)
        XCTAssertEqual(managedAbsenceEntry.end, newAbsenceEntry.end.date)

        waitForExpectations(timeout: 0.2)
    }

    func testUpdateAbsenceEntry() throws {
        var updatedAbsenceEntry = self.initialAbsenceEntry!
        updatedAbsenceEntry.start = Day().addingDays(-1)
        updatedAbsenceEntry.end = Day().addingDays(1)

        try self.coreDataService.update(absenceEntry: updatedAbsenceEntry)

        let managedAbsenceEntry: ManagedAbsenceEntry = try self.coreDataService.fetch(id: updatedAbsenceEntry.id)
        XCTAssertEqual(managedAbsenceEntry.id, updatedAbsenceEntry.id)
        XCTAssertEqual(AbsenceType(try XCTUnwrap(managedAbsenceEntry.type)), updatedAbsenceEntry.type)
        XCTAssertEqual(managedAbsenceEntry.start, updatedAbsenceEntry.start.date)
        XCTAssertEqual(managedAbsenceEntry.end, updatedAbsenceEntry.end.date)

        waitForExpectations(timeout: 0.2)
    }

    func testFetch() throws {
        let managedTimeEntry: ManagedTimeEntry = try self.coreDataService.fetch(id: self.initialTimeEntry.id)
        XCTAssertEqual(managedTimeEntry.id, self.initialTimeEntry.id)
        XCTAssertEqual(managedTimeEntry.start, self.initialTimeEntry.start)
        XCTAssertEqual(managedTimeEntry.end, self.initialTimeEntry.end)

        waitForExpectations(timeout: 0.2)
    }

    func testInsert() throws {
        let newTimeEntry = TimeEntry(start: Date(), end: nil)
        try self.coreDataService.insert() { (managedObject: ManagedTimeEntry) in
            managedObject.id = newTimeEntry.id
            managedObject.start = newTimeEntry.start
            managedObject.end = newTimeEntry.end
        }

        let managedTimeEntry: ManagedTimeEntry = try self.coreDataService.fetch(id: newTimeEntry.id)
        XCTAssertEqual(managedTimeEntry.id, newTimeEntry.id)
        XCTAssertEqual(managedTimeEntry.start, newTimeEntry.start)
        XCTAssertEqual(managedTimeEntry.end, newTimeEntry.end)

        waitForExpectations(timeout: 0.2)
    }

    func testUpdate() throws {
        var updatedTimeEntry = self.initialTimeEntry!
        updatedTimeEntry.end = nil

        try self.coreDataService.update(id: self.initialTimeEntry.id) {(managedObject: ManagedTimeEntry) in
            managedObject.start = updatedTimeEntry.start
            managedObject.end = updatedTimeEntry.end
        }

        let managedTimeEntry: ManagedTimeEntry = try self.coreDataService.fetch(id: updatedTimeEntry.id)
        XCTAssertEqual(managedTimeEntry.id, self.initialTimeEntry.id)
        XCTAssertEqual(managedTimeEntry.start, updatedTimeEntry.start)
        XCTAssertEqual(managedTimeEntry.end, updatedTimeEntry.end)

        waitForExpectations(timeout: 0.2)
    }

    func testDelete() throws {
        try self.coreDataService.delete(ManagedTimeEntry.self, id: self.initialTimeEntry.id)

        let managedTimeEntry: ManagedTimeEntry? = try? self.coreDataService.fetch(id: self.initialTimeEntry.id)
        XCTAssertNil(managedTimeEntry)

        waitForExpectations(timeout: 0.2)
    }

    func testMergeInsert() throws {
        waitForExpectations(timeout: 0.2)
        throw XCTSkip("Create another Context to simulate merging?")
    }

    func testMergeUpdate() throws {
        waitForExpectations(timeout: 0.2)
        throw XCTSkip("Create another Context to simulate merging?")
    }

    func testMergeDelete() throws {
        waitForExpectations(timeout: 0.2)
        throw XCTSkip("Create another Context to simulate merging?")
    }
}
