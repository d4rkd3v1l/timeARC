//
//  ArcViewAverage.swift
//  timeARC
//
//  Created by d4Rk on 30.01.21.
//

import SwiftUI

struct ArcViewAverage: View {
    private let minAngle: Double = 0
    private let maxAngle: Double = 250

    private let backgroundOpacity: Double = 0.33
    var overlayOpacity: Double {
        return (1 - self.backgroundOpacity) / Double(self.timeEntries.count)
    }

    let timeEntries: [Day: [TimeEntry]]
    let workingDays: [Day]
    let color: Color

    var minSeconds: Double {
        Double(self.timeEntries.values
                .flatMap { $0 }
                .map { $0.start.hoursAndMinutesInSeconds }
                .min { $0 < $1 } ?? 0)
    }

    var maxSeconds: Double {
        Double(self.timeEntries.values
                .flatMap { $0 }
                .map { $0.actualEnd.hoursAndMinutesInSeconds }
                .max { $0 < $1 } ?? 86400)
    }

    func angle(for seconds: Int) -> Angle {
        let progress = (Double(seconds) - self.minSeconds) / (self.maxSeconds - self.minSeconds)
        return .degrees(min(self.maxAngle * progress, self.maxAngle))
    }

    var body: some View {
        GeometryReader { geometry in
            let lineWidth = geometry.size.width / 10

            ZStack {
                Arc(startAngle: .degrees(self.minAngle),
                    endAngle: .degrees(self.maxAngle))
                    .strokeBorder(self.color.opacity(self.backgroundOpacity),
                                  style: StrokeStyle(lineWidth: lineWidth,
                                                     lineCap: .round,
                                                     lineJoin: .round))

                ForEach(self.timeEntries.values.flatMap({ $0 })) { timeEntry in
                    Arc(startAngle: self.angle(for: timeEntry.start.hoursAndMinutesInSeconds),
                        endAngle: self.angle(for: timeEntry.actualEnd.hoursAndMinutesInSeconds))
                        .strokeBorder(self.color.opacity(self.overlayOpacity),
                                      style: StrokeStyle(lineWidth: lineWidth,
                                                         lineCap: .butt,
                                                         lineJoin: .round))
                        .blendMode(.plusDarker)
                }

                let averageStartAngle = self.angle(for: self.timeEntries.averageWorkingHoursStartDate().hoursAndMinutesInSeconds)
                Arc(startAngle: .degrees(averageStartAngle.degrees - 0.5),
                    endAngle: .degrees(averageStartAngle.degrees + 0.5))
                    .strokeBorder(Color.contrastColor,
                                  style: StrokeStyle(lineWidth: lineWidth))

                let averageEndAngle = self.angle(for: self.timeEntries.averageWorkingHoursEndDate().hoursAndMinutesInSeconds)
                Arc(startAngle: .degrees(averageEndAngle.degrees - 0.5),
                    endAngle: .degrees(averageEndAngle.degrees + 0.5))
                    .strokeBorder(Color.contrastColor,
                                  style: StrokeStyle(lineWidth: lineWidth))

                HStack(alignment: .lastTextBaseline,
                       spacing: geometry.size.width * 0.01) {

                    Text(self.timeEntries.averageDuration(workingDays: self.workingDays).formatted(allowedUnits: [.hour, .minute]) ?? "")
                        .animatableSystemFont(size: geometry.size.width / 4.5, weight: .bold)
                        .padding(0)
                }

                HStack {
                    Text(self.timeEntries.averageWorkingHoursStartDate().formattedTime())
                        .animatableSystemFont(size: geometry.size.width / 7.5, weight: .bold)
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)

                    Spacer()

                    Text(self.timeEntries.averageWorkingHoursEndDate().formattedTime())
                        .animatableSystemFont(size: geometry.size.width / 7.5, weight: .bold)
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                }
                .frame(width: geometry.size.width * 0.65)
                .offset(x: 0, y: geometry.size.height / 3)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Preview

struct ArcViewAverage_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ArcViewAverage(timeEntries: [Day(): [TimeEntry(start: Date(hour: 7, minute: 58, second: 32),
                                                       end: Date(hour: 12, minute: 4, second: 12)),
                                             TimeEntry(start: Date(hour: 13, minute: 6, second: 3),
                                                       end: Date(hour: 17, minute: 39, second: 54))],
                                     Day().addingDays(1): [TimeEntry(start: Date(hour: 7, minute: 32, second: 12),
                                                                     end: Date(hour: 11, minute: 46, second: 33)),
                                                           TimeEntry(start: Date(hour: 12, minute: 32, second: 21),
                                                                     end: Date(hour: 16, minute: 12, second: 42))],
                                     Day().addingDays(2): [TimeEntry(start: Date(hour: 6, minute: 42, second: 10),
                                                                     end: Date(hour: 11, minute: 23, second: 34)),
                                                           TimeEntry(start: Date(hour: 11, minute: 58, second: 19),
                                                                     end: Date(hour: 15, minute: 26, second: 13))]],
                       workingDays: [Day(),
                                     Day().addingDays(1),
                                     Day().addingDays(2)],
                       color: .pink)
                .frame(width: 250)
        }
    }
}

private extension Date {
    init(hour: Int, minute: Int, second: Int) {
        let dateComponents = DateComponents(hour: hour, minute: minute, second: second)
        self = Calendar.current.date(from: dateComponents)!
    }
}
