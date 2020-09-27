//
//  Date+Strideable.swift
//  timetracker
//
//  Created by d4Rk on 27.09.20.
//

import Foundation

extension Date: Strideable {
    public func distance(to other: Date) -> TimeInterval {
        return other.timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate
    }

    public func advanced(by n: TimeInterval) -> Date {
        return self + n
    }
}
