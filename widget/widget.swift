//
//  widget.swift
//  widget
//
//  Created by d4Rk on 16.08.20.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date(),
                    timeEntries: [],
                    workingHoursPerDay: 8)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        let entry = WidgetEntry(date: Date(),
                                timeEntries: [],
                                workingHoursPerDay: 8)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [WidgetEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset, to: currentDate)!
            let entry = WidgetEntry(date: entryDate,
                                    timeEntries: [],
                                    workingHoursPerDay: 8)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct WidgetEntry: TimelineEntry {
    var date: Date

    let timeEntries: [TimeEntry]
    let workingHoursPerDay: Int
}

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) private var widgetFamily

    var entry: WidgetEntry
    @State var duration: Int = 0
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    var body: some View {
        switch self.widgetFamily {
        case .systemSmall:
            ArcViewFull(duration: self.$duration, workingHoursPerDay: self.entry.workingHoursPerDay)
            .padding(20)
            .onReceive(self.timer) { _ in
                self.duration = self.entry.timeEntries.totalDurationInSeconds(on: Date())
            }

        case .systemMedium:
            Text("Medium")

        case .systemLarge:
            Text("Large")

        @unknown default:
            fatalError()
        }
    }
}

@main
struct TimerWidget: Widget {
    let kind: String = "widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName(LocalizedStringKey("TimeTracker"))
        .description(LocalizedStringKey("Have your time tracker always in sight."))
//        .supportedFamilies([.systemSmall])
    }
}

struct widgetSmall_Previews: PreviewProvider {
    static var previews: some View {
        let entry = WidgetEntry(date: Date(),
                                timeEntries: [],
                                workingHoursPerDay: 8)
        WidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct widgetMedium_Previews: PreviewProvider {
    static var previews: some View {
        let entry = WidgetEntry(date: Date(),
                                timeEntries: [],
                                workingHoursPerDay: 8)
        WidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

struct widgetLarge_Previews: PreviewProvider {
    static var previews: some View {
        let entry = WidgetEntry(date: Date(),
                                timeEntries: [],
                                workingHoursPerDay: 8)
        WidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
