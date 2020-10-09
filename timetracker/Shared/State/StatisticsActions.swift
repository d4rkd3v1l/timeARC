//
//  StatisticsState.swift
//  timetracker
//
//  Created by d4Rk on 20.09.20.
//

import SwiftUI
import SwiftUIFlux

struct StatisticsChangeTimeFrame: Action {
    let timeFrame: TimeFrame
}

struct StatisticsNextInterval: Action {}

struct StatisticsPreviousInterval: Action {}

struct StatisticsRefresh: Action {}

