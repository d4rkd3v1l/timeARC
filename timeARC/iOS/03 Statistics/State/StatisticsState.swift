//
//  StatisticsState.swift
//  timeARC
//
//  Created by d4Rk on 20.09.20.
//

import SwiftUI
import SwiftUIFlux

struct StatisticsState: FluxState, Codable {
    var selectedTimeFrame: TimeFrame = .week
    var selectedStartDate: Date = Date()
    var selectedEndDate: Date = Date()
}
