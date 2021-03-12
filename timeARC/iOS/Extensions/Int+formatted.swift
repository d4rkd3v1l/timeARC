//
//  Int+formatted.swift
//  timeARC
//
//  Created by d4Rk on 07.03.21.
//

import Foundation

extension Int {
    func formatted(allowedUnits: NSCalendar.Unit = [.hour, .minute], zeroFormattingBehavior: DateComponentsFormatter.ZeroFormattingBehavior = .pad) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = allowedUnits
        formatter.zeroFormattingBehavior = zeroFormattingBehavior
        return formatter.string(from: DateComponents(second: self))
    }

    func formattedFull(allowedUnits: NSCalendar.Unit = [.hour, .minute]) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = allowedUnits
        formatter.unitsStyle = .full
        return formatter.string(from: Double(self))
    }
}
