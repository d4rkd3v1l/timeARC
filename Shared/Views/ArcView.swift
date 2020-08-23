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
                .stroke(self.color.opacity(0.2), style: StrokeStyle(lineWidth: geometry.size.width / 10, lineCap: .round, lineJoin: .round))
                .overlay(
                    Arc(startAngle: .degrees(0), endAngle: self.endAngle, clockwise: true)
                        .stroke(self.color, style: StrokeStyle(lineWidth: geometry.size.width / 10, lineCap: .round, lineJoin: .round))
                )
        }
    }
}

// https://www.hackingwithswift.com/books/ios-swiftui/paths-vs-shapes-in-swiftui
struct Arc: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool

    func path(in rect: CGRect) -> Path {
        let rotationAdjustment = Angle.degrees(225)
        let modifiedStart = startAngle - rotationAdjustment
        let modifiedEnd = endAngle - rotationAdjustment

        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: !clockwise)

        return path
    }
}

struct ArcViewFull: View {
    var duration: Int
    var maxDuration: Int
    var color: Color = Color.accentColor
    var allowedUnits: NSCalendar.Unit = [.hour, .minute, .second]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ArcView(color: self.color, progress: (Double(self.duration) / Double(self.maxDuration)))
                
                Text("\(Int(Double(self.duration) / Double(self.maxDuration) * 100.0))%")
                    .font(.system(size: geometry.size.width / 4)).bold()
                
                Text(self.duration.formatted(allowedUnits: self.allowedUnits) ?? "")
                    .font(.system(size: geometry.size.width / 9)).bold()
                    .offset(x: 0, y: geometry.size.height / 2.5)
            }
        }
    }
}

// MARK: - Preview

struct ArcViewFull_Previews: PreviewProvider {
    @State static var duration: Int = 123
    static var previews: some View {
        ArcViewFull(duration: duration,
                    maxDuration: 456,
                    color: .pink,
                    allowedUnits: [.hour, .minute])
            .frame(width: 250, height: 250)
    }
}
