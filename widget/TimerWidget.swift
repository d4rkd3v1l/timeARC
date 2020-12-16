//
//  widget.swift
//  widget
//
//  Created by d4Rk on 16.08.20.
//

import SwiftUI
import WidgetKit

@main
struct TimerWidget: Widget {
    let kind: String = "TimerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: self.kind, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("timeARC")
        .description("Have your timeARC always in sight.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
