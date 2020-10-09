//
//  ArcView.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 22.07.20.
//

import SwiftUI

struct ArcView: View {
    let minAngle: Double = 0
    let maxAngle: Double = 250

    let color: Color
    let progress: Double

    private var endAngle: Angle {
        return .degrees(min(self.maxAngle * self.progress, self.maxAngle))
    }

    var body: some View {
        GeometryReader { geometry in
            Arc(startAngle: .degrees(self.minAngle), endAngle: .degrees(self.maxAngle), clockwise: true)
                .strokeBorder(self.color.opacity(0.33), style: StrokeStyle(lineWidth: geometry.size.width / 10, lineCap: .round, lineJoin: .round))
                .overlay(
                    Arc(startAngle: .degrees(self.minAngle), endAngle: self.endAngle, clockwise: true)
                        .strokeBorder(self.color, style: StrokeStyle(lineWidth: geometry.size.width / 10, lineCap: .round, lineJoin: .round))
                )
        }
    }
}

// https://www.hackingwithswift.com/books/ios-swiftui/adding-strokeborder-support-with-insettableshape
struct Arc: InsettableShape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let rotationAdjustment = Angle.degrees(215)
        let modifiedStart = self.startAngle - rotationAdjustment
        let modifiedEnd = self.endAngle - rotationAdjustment

        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2 - self.insetAmount, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: !self.clockwise)

        return path
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
}

struct ArcViewFull: View {
    var duration: Int
    var maxDuration: Int
    var color: Color = Color.accentColor
    var allowedUnits: NSCalendar.Unit = [.hour, .minute, .second]
    var displayMode: TimerDisplayMode = .countUp

    func timeFontSize(for geometry: GeometryProxy) -> CGFloat {
        if self.allowedUnits == [.hour, .minute, .second] {
            return geometry.size.width / 7.5
        }

        return geometry.size.width / 5.5
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ArcView(color: self.color, progress: (Double(self.duration) / Double(max(self.maxDuration, 1))))

                HStack(alignment: .lastTextBaseline, spacing: geometry.size.width * 0.01) {
                    Text("\(Int(Double(self.duration) / Double(max(self.maxDuration, 1)) * 100.0))")
                        .animatableSystemFont(size: geometry.size.width / 3.5, weight: .bold)
                        .padding(0)

                    Text("%")
                        .animatableSystemFont(size: geometry.size.width / 4.5, weight: .bold)
                        .padding(0)
                }

                Text(self.displayMode.text(for: self.duration, maxDuration: self.maxDuration, allowedUnits: self.allowedUnits))
                    .animatableSystemFont(size: self.timeFontSize(for: geometry), weight: .bold)
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
                    .frame(width: geometry.size.width * 0.65)
                    .offset(x: 0, y: geometry.size.height / 3)
            }
        }
    }
}

enum TimerDisplayMode: String, Codable {
    case countUp
    case countDown
    case endOfWorkingDay
    case progress

    var next: TimerDisplayMode {
        switch self {
        case .countUp:          return .countDown
        case .countDown:        return .endOfWorkingDay
        case .endOfWorkingDay:  return .countUp
        case .progress:         return .countUp
        }
    }

    func text(for duration: Int, maxDuration: Int, allowedUnits: NSCalendar.Unit) -> String {
        switch self {
        case .countUp:
            return duration.formatted(allowedUnits: allowedUnits) ?? ""

        case .countDown:
            return (duration - maxDuration).formatted(allowedUnits: allowedUnits) ?? ""

        case .endOfWorkingDay:
            let format: String
            if allowedUnits == [.hour, .minute, .second] {
                format = "HH:mm:ss"
            } else {
                format = "HH:mm"
            }

            return Date().addingTimeInterval(TimeInterval(maxDuration - duration)).formatted(format)

        case .progress:
            return "\(duration.formatted(allowedUnits: allowedUnits, zeroFormattingBehavior: .default) ?? "") / \(maxDuration.formatted(allowedUnits: allowedUnits, zeroFormattingBehavior: .default) ?? "")"
        }
    }
}

// MARK: - Preview

struct ArcViewFull_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ArcViewFull(duration: 123,
                        maxDuration: 456,
                        color: .pink,
                        allowedUnits: [.second],
                        displayMode: .progress)
                .frame(width: 250, height: 250)

            ArcViewFull(duration: 1,
                        maxDuration: 100,
                        color: .pink,
                        allowedUnits: [.hour, .minute, .second],
                        displayMode: .endOfWorkingDay)
                .frame(width: 250, height: 250)
            HStack {
                ArcViewFull(duration: 123,
                            maxDuration: 456,
                            color: .pink,
                            allowedUnits: [.hour, .minute])
                    .frame(width: 100, height: 100)

                ArcViewFull(duration: 123,
                            maxDuration: 456,
                            color: .pink,
                            allowedUnits: [.hour, .minute, .second],
                            displayMode: .countDown)
                    .frame(width: 100, height: 100)
            }
            HStack {
                ArcViewFull(duration: 123,
                            maxDuration: 456,
                            color: .pink,
                            allowedUnits: [.hour, .minute])
                    .frame(width: 50, height: 50)

                ArcViewFull(duration: 123,
                            maxDuration: 456,
                            color: .pink,
                            allowedUnits: [.hour, .minute],
                            displayMode: .countDown)
                    .frame(width: 50, height: 50)
            }
        }
    }
}
