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
                    accentColor: .green,
                    displayMode: .countUp)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        let entry = WidgetEntry(date: Date(),
                                duration: 2520,
                                maxDuration: 28800,
                                isRunning: true,
                                accentColor: .green,
                                displayMode: .countUp)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        guard let userDefaults = UserDefaults(suiteName: "group.com.d4Rk.timetracker"),
              let decodedWidgetData = userDefaults.data(forKey: "widgetData"),
              let widgetData = try? JSONDecoder().decode(WidgetData.self, from: decodedWidgetData) else { return }

        let isRunning = widgetData.timeEntries.isTimerRunning
        let duration = widgetData.timeEntries.forDay(Date().day).totalDurationInSeconds

        if isRunning {
            var entries: [WidgetEntry] = []
            for index in 0..<1440 { // 24h should be sufficient?! -> TODO: Check if Timeline.policy acutally works, then this time could be reduced. Trigger first update now, and every following one to the full minute? This would increase precision between Widget and App.
                let nextMinute = index * 60
                let entry = WidgetEntry(date: Date().addingTimeInterval(TimeInterval(nextMinute)),
                                        duration: duration + nextMinute,
                                        maxDuration: widgetData.workingMinutesPerDay * 60,
                                        isRunning: true,
                                        accentColor: widgetData.accentColor.color,
                                        displayMode: widgetData.displayMode)
                entries.append(entry)
            }

            let timeline = Timeline(entries: entries, policy: .after(entries.last!.date))
            completion(timeline)
        } else {
            let entry = WidgetEntry(date: Date(),
                                    duration: duration,
                                    maxDuration: widgetData.workingMinutesPerDay * 60,
                                    isRunning: false,
                                    accentColor: widgetData.accentColor.color,
                                    displayMode: widgetData.displayMode)

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
    let displayMode: TimerDisplayMode

//    let averageDuration: Int
//    let averageBreaksDuration: Int
//    let averageOvertimeDuration: Int
//    let totalDuration: Int
//    let totalBreaksDuration: Int
//    let totalOvertimeDuration: Int
}

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    var entry: WidgetEntry

    @ViewBuilder var body: some View {
        GeometryReader { geometry in
            switch self.widgetFamily {
            case .systemSmall:
                ArcViewFull(duration: self.entry.duration,
                            maxDuration: self.entry.maxDuration,
                            color: self.entry.isRunning ? .accentColor : .gray,
                            allowedUnits: [.hour, .minute],
                            displayMode: entry.displayMode)
                    .padding()
                    .aspectRatio(1, contentMode: .fit)
                    .accentColor(entry.accentColor)

            case .systemMedium:
                HStack {
                    ArcViewFull(duration: self.entry.duration,
                                maxDuration: self.entry.maxDuration,
                                color: self.entry.isRunning ? .accentColor : .gray,
                                allowedUnits: [.hour, .minute],
                                displayMode: entry.displayMode)
                        .padding()
                        .aspectRatio(1, contentMode: .fit)
                        .accentColor(entry.accentColor)

                    VStack {
                        Text("week")
                            .font(.title2)
                            .bold()

                        Spacer()

                        HStack {
                            Text("hours")
                            Spacer()
                            Text("34:34")
                        }

                        Divider()

                        HStack {
                            Text("breaks")
                            Spacer()
                            Text("0:34")
                        }

                        Divider()

                        HStack {
                            Text("overtime")
                            Spacer()
                            Text("1:51")
                        }
                    }
                    .font(.footnote)
                    .padding(.all, 10)
                    .background(Color.primary.opacity(0.15))
                }

            case .systemLarge:
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("today")
                                .font(.title2)
                                .bold()

                            ArcViewFull(duration: self.entry.duration,
                                        maxDuration: self.entry.maxDuration,
                                        color: self.entry.isRunning ? .accentColor : .gray,
                                        allowedUnits: [.hour, .minute],
                                        displayMode: entry.displayMode)
                                .aspectRatio(1, contentMode: .fit)
                                .accentColor(entry.accentColor)
                        }
                        .padding(.all, 10)
                        .background(Color.primary.opacity(0.15))
                        .cornerRadius(14)

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text("week")
                                .font(.title2)
                                .bold()

                            ArcViewFull(duration: self.entry.duration,
                                        maxDuration: self.entry.maxDuration,
                                        color: self.entry.isRunning ? .accentColor : .gray,
                                        allowedUnits: [.hour, .minute],
                                        displayMode: entry.displayMode)
                                .aspectRatio(1, contentMode: .fit)
                                .accentColor(entry.accentColor)
                        }
                        .padding(.all, 10)
                    }

                    Spacer()

                    VStack(alignment: .center, spacing: 10) {
                        HStack(alignment: .top, spacing: 0) {
                            VStack(alignment: .leading, spacing: nil) {
                                Text("week").bold().hidden()
                                Divider()
                                Text("hours")
                                Divider()
                                Text("breaks")
                                Divider()
                                Text("overtime")
                            }

                            VStack(alignment: .trailing, spacing: nil) {
                                Text("averages").bold()
                                Divider()
                                Text("8:34")
                                Divider()
                                Text("0:45")
                                Divider()
                                Text("0:15")
                            }

                            VStack(alignment: .trailing, spacing: nil) {
                                Text("totals").bold()
                                Divider()
                                Text("13:08")
                                Divider()
                                Text("2:32")
                                Divider()
                                Text("0:30")
                            }
                        }
                    }
                    .font(.footnote)
                }
                .padding(.all)

            @unknown default:
                fatalError()
            }
        }
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
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Previews

struct TimerWidgetSmall_Previews: PreviewProvider {
    static var previews: some View {
        let entry = WidgetEntry(date: Date(),
                                duration: 2520,
                                maxDuration: 28800,
                                isRunning: true,
                                accentColor: .green,
                                displayMode: .countUp)

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
                                accentColor: .green,
                                displayMode: .countDown)

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
                                accentColor: .green,
                                displayMode: .endOfWorkingDay)

        return WidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
