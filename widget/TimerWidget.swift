//
//  widget.swift
//  widget
//
//  Created by d4Rk on 16.08.20.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date(),
                    duration: 2520,
                    maxDuration: 28800,
                    isRunning: true,
                    accentColor: .green)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        let entry = WidgetEntry(date: Date(),
                                duration: 2520,
                                maxDuration: 28800,
                                isRunning: true,
                                accentColor: .green)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        guard let userDefaults = UserDefaults(suiteName: "group.com.d4Rk.timetracker"),
              let decodedWidgetData = userDefaults.data(forKey: "widgetData"),
              let widgetData = try? JSONDecoder().decode(WidgetData.self, from: decodedWidgetData) else { return }

        let isRunning = widgetData.timeEntries.isTimerRunning
        let duration = widgetData.timeEntries.totalDurationInSeconds

        if isRunning {
            var entries: [WidgetEntry] = []
            for index in 0..<1440 { // 24h should be sufficient?! -> check if Timeline.policy acutally works, then this time could be reduced. Trigger first update now, and every following one to the full minute? This would increase precision between Widget and App.
                let nextMinute = index * 60
                let entry = WidgetEntry(date: Date().addingTimeInterval(TimeInterval(nextMinute)),
                                        duration: duration + nextMinute,
                                        maxDuration: widgetData.workingMinutesPerDay * 60,
                                        isRunning: true,
                                        accentColor: widgetData.accentColor.color)
                entries.append(entry)
            }

            let timeline = Timeline(entries: entries, policy: .after(entries.last!.date))
            completion(timeline)
        } else {
            let entry = WidgetEntry(date: Date(),
                                    duration: duration,
                                    maxDuration: widgetData.workingMinutesPerDay * 60,
                                    isRunning: false,
                                    accentColor: widgetData.accentColor.color)

            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
        }
    }
}

struct WidgetEntry: TimelineEntry {
    var date: Date

    let duration: Int
    let maxDuration: Int
    let isRunning: Bool
    let accentColor: Color
}

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    var entry: WidgetEntry

    var body: some View {
//        switch self.widgetFamily {
//        case .systemSmall:
        return ZStack {
            ArcViewFull(duration: self.entry.duration,
                        maxDuration: self.entry.maxDuration,
                        color: self.entry.isRunning ? .accentColor : .gray,
                        allowedUnits: [.hour, .minute])
            .padding(20)
        }
        .accentColor(entry.accentColor)
//
//        case .systemMedium:
//            Text("Medium")
//
//        case .systemLarge:
//            Text("Large")
//
//        @unknown default:
//            fatalError()
//        }
    }
}

@main
struct TimerWidget: Widget {
    let kind: String = "TimerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("TimeTracker")
        .description("Have your time tracker always in sight.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Previews

struct TimerWidgetSmall_Previews: PreviewProvider {
    static var previews: some View {
        let entry = WidgetEntry(date: Date(),
                                duration: 2520,
                                maxDuration: 28800,
                                isRunning: true,
                                accentColor: .green)

        return WidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct TimerWidgetMedium_Previews: PreviewProvider {
    static var previews: some View {
        let entry = WidgetEntry(date: Date(),
                                duration: 2520,
                                maxDuration: 28800,
                                isRunning: true,
                                accentColor: .green)

        return WidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

struct TimerWidgetLarge_Previews: PreviewProvider {
    static var previews: some View {
        let entry = WidgetEntry(date: Date(),
                                duration: 2520,
                                maxDuration: 28800,
                                isRunning: true,
                                accentColor: .green)

        return WidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
