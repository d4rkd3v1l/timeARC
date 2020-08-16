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
        guard let userDefaults = UserDefaults(suiteName: "group.com.d4Rk.timetracker"),
              let decodedState = userDefaults.data(forKey: "appState"),
              let appState = try? JSONDecoder().decode(AppState.self, from: decodedState) else { return }

        let widgetEntry = WidgetEntry(date: Date(),
                                      timeEntries: appState.timeState.timeEntries,
                                      workingHoursPerDay: appState.settingsState.workingHoursPerDay)

        let timeline = Timeline(entries: [widgetEntry], policy: .after(Date().addingTimeInterval(10)))
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
    @State var duration: Int
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    var body: some View {
//        switch self.widgetFamily {
//        case .systemSmall:
        return VStack {
            ArcViewFull(duration: self.$duration, workingHoursPerDay: self.entry.workingHoursPerDay)
            .padding(20)
            .onReceive(self.timer) { _ in
                self.duration = self.entry.timeEntries.totalDurationInSeconds(on: Date())
            }
        }
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
            WidgetEntryView(entry: entry, duration: entry.timeEntries.totalDurationInSeconds(on: Date()))
        }
        .configurationDisplayName(LocalizedStringKey("TimeTracker"))
        .description(LocalizedStringKey("Have your time tracker always in sight."))
//        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Previews
//
//struct TimerWidgetSmall_Previews: PreviewProvider {
//    static var previews: some View {
//        let entry = WidgetEntry(date: Date(),
//                                timeEntries: [],
//                                workingHoursPerDay: 8)
//
//        return WidgetEntryView(entry: entry)
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//            .accentColor(.green)
//    }
//}
//
//struct TimerWidgetMedium_Previews: PreviewProvider {
//    static var previews: some View {
//        let entry = WidgetEntry(date: Date(),
//                                timeEntries: [],
//                                workingHoursPerDay: 8)
//        return WidgetEntryView(entry: entry)
//            .previewContext(WidgetPreviewContext(family: .systemMedium))
//            .accentColor(.green)
//    }
//}
//
//struct TimerWidgetLarge_Previews: PreviewProvider {
//    static var previews: some View {
//        let entry = WidgetEntry(date: Date(),
//                                timeEntries: [],
//                                workingHoursPerDay: 8)
//        return WidgetEntryView(entry: entry)
//            .previewContext(WidgetPreviewContext(family: .systemLarge))
//            .accentColor(.green)
//    }
//}
