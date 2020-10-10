//
//  AbsenceEntryTests.swift
//  timetrackerTests
//
//  Created by d4Rk on 10.10.20.
//

import XCTest
@testable import timetracker

class AbsenceEntryTests: XCTestCase {
    let absenceTypes: [AbsenceType] = [AbsenceType(id: UUID(), title: "bankHoliday", icon: "🙌", offPercentage: 1),
                                       AbsenceType(id: UUID(), title: "holiday", icon: "🏝", offPercentage: 1),
                                       AbsenceType(id: UUID(), title: "sick", icon: "🤒", offPercentage: 1),
                                       AbsenceType(id: UUID(), title: "childSick", icon: "🤒🧒", offPercentage: 1),
                                       AbsenceType(id: UUID(), title: "vocationalSchool", icon: "🏫", offPercentage: 1),
                                       AbsenceType(id: UUID(), title: "parentalLeave", icon: "🧒", offPercentage: 1),
                                       AbsenceType(id: UUID(), title: "training", icon: "📚", offPercentage: 1)]

    func testAbsenceEntryInit() throws {
        let dateStart = Date()
        let dateEnd = Date().addingTimeInterval(216000)
        
        let absenceEntry = AbsenceEntry(type: self.absenceTypes[0], startDate: dateStart, endDate: dateEnd)

        XCTAssertEqual(absenceEntry.type.id, self.absenceTypes[0].id)
        XCTAssertEqual(absenceEntry.startDate, dateStart.startOfDay)
        XCTAssertEqual(absenceEntry.endDate, dateEnd.startOfDay)
    }

    func testAbsenceEntriesForDay() throws {
        let dateComponentsStart1 = DateComponents(year: 2020, month: 07, day: 20, hour: 13, minute: 37, second: 42)
        let dateStart1 = try XCTUnwrap(Calendar.current.date(from: dateComponentsStart1))
        let dateComponentsEnd1 = DateComponents(year: 2020, month: 07, day: 25, hour: 12, minute: 2, second: 1)
        let dateEnd1 = try XCTUnwrap(Calendar.current.date(from: dateComponentsEnd1))
        let absenceEntry1 = AbsenceEntry(type: self.absenceTypes[0], startDate: dateStart1, endDate: dateEnd1)

        let dateComponentsStart2 = DateComponents(year: 2020, month: 07, day: 23, hour: 13, minute: 37, second: 42)
        let dateStart2 = try XCTUnwrap(Calendar.current.date(from: dateComponentsStart2))
        let dateComponentsEnd2 = DateComponents(year: 2020, month: 07, day: 26, hour: 12, minute: 2, second: 1)
        let dateEnd2 = try XCTUnwrap(Calendar.current.date(from: dateComponentsEnd2))
        let absenceEntry2 = AbsenceEntry(type: self.absenceTypes[2], startDate: dateStart2, endDate: dateEnd2)

        let absenceEntries = [absenceEntry1, absenceEntry2]

        let dateComponentsBefore = DateComponents(year: 2020, month: 07, day: 19, hour: 22, minute: 32, second: 13)
        let dateBefore = try XCTUnwrap(Calendar.current.date(from: dateComponentsBefore))

        XCTAssertTrue(absenceEntries.absenceEntriesFor(day: dateBefore).isEmpty)
        XCTAssertEqual(absenceEntries.absenceEntriesFor(day: dateStart1).count, 1)
        XCTAssertEqual(absenceEntries.absenceEntriesFor(day: dateEnd1).count, 2)
        XCTAssertEqual(absenceEntries.absenceEntriesFor(day: dateEnd2).count, 1)
    }
}
