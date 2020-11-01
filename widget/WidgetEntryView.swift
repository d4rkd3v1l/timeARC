//
//  WidgetEntryView.swift
//  timetracker
//
//  Created by d4Rk on 01.11.20.
//

import SwiftUI
import WidgetKit

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    let entry: WidgetEntry

    @ViewBuilder var body: some View {
        GeometryReader { geometry in
            switch self.widgetFamily {
            case .systemSmall:
                ArcViewFull(duration: self.entry.todayDuration,
                            maxDuration: self.entry.todayMaxDuration,
                            color: self.entry.isRunning ? .accentColor : .gray,
                            allowedUnits: [.hour, .minute],
                            displayMode: entry.displayMode)
                    .padding()
                    .aspectRatio(1, contentMode: .fit)
                    .accentColor(entry.accentColor)

            case .systemMedium:
                HStack {
                    ArcViewFull(duration: self.entry.todayDuration,
                                maxDuration: self.entry.todayMaxDuration,
                                color: self.entry.isRunning ? .accentColor : .gray,
                                allowedUnits: [.hour, .minute],
                                displayMode: self.entry.displayMode)
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
                            Text(self.entry.weekDuration.formatted() ?? "")
                        }

                        Divider()

                        HStack {
                            Text("breaks")
                            Spacer()
                            Text(self.entry.weekTotalBreaksDuration.formatted() ?? "")
                        }

                        Divider()

                        HStack {
                            Text("overtime")
                            Spacer()
                            Text(self.entry.weekTotalOvertimeDuration.formatted() ?? "")
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

                            ArcViewFull(duration: self.entry.todayDuration,
                                        maxDuration: self.entry.todayMaxDuration,
                                        color: self.entry.isRunning ? .accentColor : .gray,
                                        allowedUnits: [.hour, .minute],
                                        displayMode: self.entry.displayMode)
                                .aspectRatio(1, contentMode: .fit)
                                .accentColor(self.entry.accentColor)
                        }
                        .padding(.all, 10)
                        .background(Color.primary.opacity(0.15))
                        .cornerRadius(12)

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text("week")
                                .font(.title2)
                                .bold()

                            ArcViewFull(duration: self.entry.weekDuration,
                                        maxDuration: self.entry.weekMaxDuration,
                                        color: self.entry.isRunning ? .accentColor : .gray,
                                        allowedUnits: [.hour, .minute],
                                        displayMode: self.entry.displayMode)
                                .aspectRatio(1, contentMode: .fit)
                                .accentColor(self.entry.accentColor)
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
                                Text(self.entry.weekAverageDuration.formatted() ?? "")
                                Divider()
                                Text(self.entry.weekAverageBreaksDuration.formatted() ?? "")
                                Divider()
                                Text(self.entry.weekAverageOvertimeDuration.formatted() ?? "")
                            }

                            VStack(alignment: .trailing, spacing: nil) {
                                Text("totals").bold()
                                Divider()
                                Text(self.entry.weekDuration.formatted() ?? "")
                                Divider()
                                Text(self.entry.weekTotalBreaksDuration.formatted() ?? "")
                                Divider()
                                Text(self.entry.weekTotalOvertimeDuration.formatted() ?? "")
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

// MARK: - Previews

struct TimerWidgetSmall_Previews: PreviewProvider {
    static var previews: some View {
        let entry = Provider().providePlaceholder()
        return WidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct TimerWidgetMedium_Previews: PreviewProvider {
    static var previews: some View {
        let entry = Provider().providePlaceholder()
        return WidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

struct TimerWidgetLarge_Previews: PreviewProvider {
    static var previews: some View {
        let entry = Provider().providePlaceholder()
        return WidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
