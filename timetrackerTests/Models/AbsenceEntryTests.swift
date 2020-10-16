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

    func testInit() throws {
        let dayStart = Day()
        let dayEnd = Day().addingDays(3)
        
        let absenceEntry = AbsenceEntry(type: self.absenceTypes[0],
                                        start: dayStart,
                                        end: dayEnd)

        XCTAssertEqual(absenceEntry.type.id, self.absenceTypes[0].id)
        XCTAssertEqual(absenceEntry.start, dayStart)
        XCTAssertEqual(absenceEntry.end, dayEnd)
    }

    func testUpdate() throws {
        var absenceEntry = AbsenceEntry(type: self.absenceTypes[0],
                                        start: Day(),
                                        end: Day().addingDays(2))

        let oldId = absenceEntry.id
        let newAbsenceType = self.absenceTypes[1]
        let newStart = Day().addingDays(-1)
        let newEnd = Day().addingDays(1)
        absenceEntry.update(type: self.absenceTypes[1], start: newStart, end: newEnd)

        XCTAssertEqual(absenceEntry.id, oldId)
        XCTAssertEqual(absenceEntry.type, newAbsenceType)
        XCTAssertEqual(absenceEntry.start, newStart)
        XCTAssertEqual(absenceEntry.end, newEnd)
    }

    func testRelevantDays() throws {
        let absenceEntry = AbsenceEntry(type: self.absenceTypes[0],
                                        start: Day(),
                                        end: Day().addingDays(2))

        XCTAssertEqual(absenceEntry.relevantDays, [Day(),
                                                   Day().addingDays(1),
                                                   Day().addingDays(2)])
    }

    func testEquatable() throws {
        let absenceEntry = AbsenceEntry(type: self.absenceTypes[0],
                                        start: Day(),
                                        end: Day().addingDays(2))

        var absenceEntry1 = absenceEntry
        absenceEntry1.update(type: self.absenceTypes[3],
                             start: Day().addingDays(-1),
                             end: Day())

        var absenceEntry2 = absenceEntry
        absenceEntry2.update(type: self.absenceTypes[4],
                             start: Day().addingDays(3),
                             end: Day().addingDays(8))

        XCTAssertEqual(absenceEntry1, absenceEntry2)
    }

    func testAbsenceEntriesForDay() throws {
        let dateComponentsStart1 = DateComponents(year: 2020, month: 07, day: 20, hour: 13, minute: 37, second: 42)
        let dateStart1 = try XCTUnwrap(Calendar.current.date(from: dateComponentsStart1))
        let dateComponentsEnd1 = DateComponents(year: 2020, month: 07, day: 25, hour: 12, minute: 2, second: 1)
        let dateEnd1 = try XCTUnwrap(Calendar.current.date(from: dateComponentsEnd1))
        let absenceEntry1 = AbsenceEntry(type: self.absenceTypes[0], start: dateStart1.day, end: dateEnd1.day)

        let dateComponentsStart2 = DateComponents(year: 2020, month: 07, day: 23, hour: 13, minute: 37, second: 42)
        let dateStart2 = try XCTUnwrap(Calendar.current.date(from: dateComponentsStart2))
        let dateComponentsEnd2 = DateComponents(year: 2020, month: 07, day: 26, hour: 12, minute: 2, second: 1)
        let dateEnd2 = try XCTUnwrap(Calendar.current.date(from: dateComponentsEnd2))
        let absenceEntry2 = AbsenceEntry(type: self.absenceTypes[2], start: dateStart2.day, end: dateEnd2.day)

        let absenceEntries = [absenceEntry1, absenceEntry2]

        let dateComponentsBefore = DateComponents(year: 2020, month: 07, day: 19, hour: 22, minute: 32, second: 13)
        let dateBefore = try XCTUnwrap(Calendar.current.date(from: dateComponentsBefore))

        XCTAssertTrue(absenceEntries.absenceEntriesFor(day: dateBefore.day).isEmpty)
        XCTAssertEqual(absenceEntries.absenceEntriesFor(day: dateStart1.day).count, 1)
        XCTAssertEqual(absenceEntries.absenceEntriesFor(day: dateEnd1.day).count, 2)
        XCTAssertEqual(absenceEntries.absenceEntriesFor(day: dateEnd2.day).count, 1)
    }
}
