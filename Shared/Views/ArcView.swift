//
//  ArcView.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 22.07.20.
//

import SwiftUI

struct ArcView: View {
    let color: Color
    let progress: Double

    private var endAngle: Angle {
        return .degrees(min(270 * self.progress, 270))
    }

    var body: some View {
        GeometryReader { geometry in
            Arc(startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)
                .strokeBorder(self.color.opacity(0.33), style: StrokeStyle(lineWidth: geometry.size.width / 10, lineCap: .round, lineJoin: .round))
                .overlay(
                    Arc(startAngle: .degrees(0), endAngle: self.endAngle, clockwise: true)
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
        let rotationAdjustment = Angle.degrees(225)
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
            return geometry.size.width / 9.5
        }

        return geometry.size.width / 6.5
    }

    var text: String {
        switch self.displayMode {
        case .countUp:
            return self.duration.formatted(allowedUnits: self.allowedUnits) ?? ""

        case .countDown:
            return (self.duration - self.maxDuration).formatted(allowedUnits: self.allowedUnits) ?? ""

        case .endOfWorkingDay:
            return Date().addingTimeInterval(TimeInterval(self.maxDuration - self.duration)).formatted("HH:mm:ss")

        case .progress:
            return "\(self.duration.formatted(allowedUnits: self.allowedUnits, zeroFormattingBehavior: .default) ?? "") / \(self.maxDuration.formatted(allowedUnits: self.allowedUnits, zeroFormattingBehavior: .default) ?? "")"
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ArcView(color: self.color, progress: (Double(self.duration) / Double(self.maxDuration)))
                
                Text("\(Int(Double(self.duration) / Double(self.maxDuration) * 100.0))%")
                    .animatableSystemFont(size: geometry.size.width / 4, weight: .bold)
                
                Text(self.text)
                    .animatableSystemFont(size: self.timeFontSize(for: geometry), weight: .bold)
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
                    .frame(width: geometry.size.width * 0.5)
                    .offset(x: 0, y: geometry.size.height / 2.75)
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

            ArcViewFull(duration: 123,
                        maxDuration: 456,
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
                            allowedUnits: [.hour, .minute, .second])
                    .frame(width: 50, height: 50)
            }
        }
    }
}
