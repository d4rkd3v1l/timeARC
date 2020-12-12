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
        switch self.widgetFamily {
        case .systemSmall:
            self.smallWidget()

        case .systemMedium:
            self.mediumWidget()

        case .systemLarge:
            self.largeWidget()

        @unknown default:
            fatalError()
        }
    }

    //MARK: Small

    private func smallWidget() -> some View {
        Group {
            if self.entry.isTodayWorkingDay {
                ArcViewFull(duration: self.entry.todayDuration,
                            maxDuration: self.entry.todayMaxDuration,
                            color: self.entry.isRunning ? .accentColor : .gray,
                            allowedUnits: [.hour, .minute],
                            displayMode: entry.displayMode)
                    .padding()
                    .aspectRatio(1, contentMode: .fit)
                    .accentColor(entry.accentColor)
            } else {
                self.freeTimeView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .gradientBackground()
    }

    // MARK: Medium

    private func mediumWidget() -> some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                Group {
                    if self.entry.isTodayWorkingDay {
                        ArcViewFull(duration: self.entry.todayDuration,
                                    maxDuration: self.entry.todayMaxDuration,
                                    color: self.entry.isRunning ? .accentColor : .gray,
                                    allowedUnits: [.hour, .minute],
                                    displayMode: self.entry.displayMode)
                            .padding()
                            .aspectRatio(1, contentMode: .fit)
                            .accentColor(entry.accentColor)
                    } else {
                        self.freeTimeView()
                    }
                }
                .frame(width: proxy.size.width/2)

                Divider()

                Group {
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
                }
                .frame(width: proxy.size.width/2)
            }
            .gradientBackground()
        }
    }

    // MARK: Large

    private func largeWidget() -> some View {
        VStack {
            GeometryReader { proxy in
                HStack {
                    // Today
                    Group {
                        if self.entry.isTodayWorkingDay {
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
                        } else {
                            self.freeTimeView()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.all, 10)
                    .background(Color("TodayBackground"))
                    .cornerRadius(12)
                    .frame(width: proxy.size.width / 2)

                    Spacer()

                    // Week
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
                    .frame(width: proxy.size.width / 2)
                }
            }

            Spacer(minLength: 20)

            // Table (Stats)
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
        .padding(.all, 15)
        .gradientBackground()
    }

    // MARK: Misc

    private func freeTimeView() -> some View {
        VStack {
            Spacer()
            Spacer()
            Text("🥳")
                .font(.system(size: 60))
            Spacer()
            Text("Free time!").bold()
            Spacer()
            Spacer()
        }
    }
}

struct GradientBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        return content.background(LinearGradient(gradient: Gradient(colors: [Color("BackgroundGradientFirst"),
                                                                             Color("BackgroundGradientSecond")]),
                                                 startPoint: .topLeading,
                                                 endPoint: .bottomTrailing))
    }
}

extension View {
    func gradientBackground() -> some View {
        self.modifier(GradientBackgroundModifier())
    }
}

// MARK: - Previews

struct TimerWidgetLight_Previews: PreviewProvider {
    static var previews: some View {
        let entry = Provider().providePlaceholder()
        let entryNoWorkingDay = Provider().providePlaceholder(isTodayWorkingDay: false)

        return Group {
            WidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            WidgetEntryView(entry: entryNoWorkingDay)
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            WidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            WidgetEntryView(entry: entryNoWorkingDay)
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            WidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            WidgetEntryView(entry: entryNoWorkingDay)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
        .environment(\.colorScheme, .light)
    }
}

struct TimerWidgetDark_Previews: PreviewProvider {
    static var previews: some View {
        let entry = Provider().providePlaceholder()
        let entryNoWorkingDay = Provider().providePlaceholder(isTodayWorkingDay: false)

        return Group {
            WidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            WidgetEntryView(entry: entryNoWorkingDay)
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            WidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            WidgetEntryView(entry: entryNoWorkingDay)
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            WidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            WidgetEntryView(entry: entryNoWorkingDay)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
        .environment(\.colorScheme, .dark)
    }
}
