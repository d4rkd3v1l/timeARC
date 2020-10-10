//
//  TimerState.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import Foundation
import SwiftUIFlux

struct TimeState: FluxState, Codable {
    /// `Date` is start of day, `TimeEntry`s are sorted by start ascending
    var timeEntries: [Day: [TimeEntry]] = [:]
    var absenceEntries: [AbsenceEntry] = []
    var displayMode: TimerDisplayMode = .countUp
    var didSyncWatchData: Bool = false

    private enum CodingKeys: String, CodingKey {
        case timeEntries
        case absenceEntries
        case displayMode
    }
}

extension TimeState {
    /// - Does automatically split `TimeEntry`s into single days, that would otherwise span multiple days
    /// - `TimeEntry`s for each day are sorted ascending by their `start` date
    mutating func insertTimeEntryValidated(_ timeEntry: TimeEntry) {
        timeEntry.splittedIntoSingleDays().forEach { timeEntry in
            let day = timeEntry.start.day
            if !(self.timeEntries[day]?.isEmpty ?? false) {
                self.timeEntries[day] = []
            }

            self.timeEntries[day]?.append(timeEntry)
            self.timeEntries[day] = self.timeEntries[day]?.mergedOverlappingEntries()
        }
    }

    mutating func updateTimeEntryValidated(_ timeEntry: TimeEntry) {
        guard let oldTimeEntry = self.timeEntries.find(timeEntry) else { return }

        var newTimeEntry = oldTimeEntry
        newTimeEntry.start = timeEntry.start
        newTimeEntry.end = timeEntry.end

        self.removeTimeEntry(oldTimeEntry)
        self.insertTimeEntryValidated(newTimeEntry)
    }

    mutating func removeTimeEntry(_ timeEntry: TimeEntry) {
        let day = timeEntry.start.day
        self.timeEntries[day]?.removeAll(where: { $0.id == timeEntry.id })

        if self.timeEntries[day]?.isEmpty ?? false &&
            !self.absenceEntries.flatMap({ $0.relevantDays }).contains(day) {
            self.timeEntries.removeValue(forKey: day)
        }
    }

    mutating func insertAbsenceEntry(_ absenceEntry: AbsenceEntry) {
        self.absenceEntries.append(absenceEntry)

        absenceEntry.relevantDays.forEach { day in
            if !self.timeEntries.keys.contains(day) {
                self.timeEntries[day] = []
            }
        }
    }

    mutating func updateAbsenceEntry(_ absenceEntry: AbsenceEntry) {
        guard let oldAbsenceEntry = self.absenceEntries.first(where: { $0 == absenceEntry }) else { return }

        var newAbsenceEntry = oldAbsenceEntry
        newAbsenceEntry.update(type: absenceEntry.type,
                               start: absenceEntry.start,
                               end: absenceEntry.end)

        self.removeAbsenceEntry(oldAbsenceEntry, onlyFor: nil)
        self.insertAbsenceEntry(newAbsenceEntry)
    }

    mutating func removeAbsenceEntry(_ absenceEntry: AbsenceEntry, onlyFor day: Day?) {
        self.absenceEntries.removeAll(where: { $0 == absenceEntry })

        absenceEntry.relevantDays.forEach { day in
            if let timeEntriesForDay = self.timeEntries[day],
               timeEntriesForDay.isEmpty {
                self.timeEntries.removeValue(forKey: day)
            }
        }

        if let day = day {
            let updatedEntries = absenceEntry.removed(day: day)
            updatedEntries.forEach { entry in
                self.insertAbsenceEntry(entry)
            }
        }
    }
}

extension AbsenceEntry {
    func removed(day: Day) -> [AbsenceEntry] {
        let relevantDays = self.relevantDays

        let isOnlyRelevantDay = relevantDays.count == 1 && relevantDays[0] == day
        guard !isOnlyRelevantDay else { return [] }

        guard let index = relevantDays.firstIndex(of: day) else { return [self] }

        var result: [AbsenceEntry] = []

        switch index {
        case 0:
            let newEntry = AbsenceEntry(type: self.type,
                                        start: day.addingDays(1),
                                        end: self.end)
            result.append(newEntry)

        case (relevantDays.count - 1):
            let newEntry = AbsenceEntry(type: self.type,
                                        start: self.start,
                                        end: self.end.addingDays(-1))
            result.append(newEntry)

        default:
            let newEntry1 = AbsenceEntry(type: self.type,
                                         start: self.start,
                                         end: day.addingDays(-1))
            result.append(newEntry1)
            
            let newEntry2 = AbsenceEntry(type: self.type,
                                         start: day.addingDays(1),
                                         end: self.end)
            result.append(newEntry2)
        }
        
        return result
    }
}
