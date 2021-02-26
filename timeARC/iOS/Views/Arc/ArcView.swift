//
//  ArcView.swift
//  timeARC
//
//  Created by d4Rk on 22.07.20.
//

import SwiftUI

struct ArcView: View {
    let minAngle: Angle = .degrees(0)
    let maxAngle: Angle = .degrees(250)
    let backgroundOpacity: Double = 0.33

    let color: Color
    let progress: Double

    private var endAngle: Angle {
        return .degrees(min(self.maxAngle.degrees * self.progress, self.maxAngle.degrees))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let lineWidth = geometry.size.width / 10

                Arc(startAngle: self.minAngle,
                    endAngle: self.maxAngle)
                    .strokeBorder(self.color.opacity(self.backgroundOpacity),
                                  style: StrokeStyle(lineWidth: lineWidth,
                                                     lineCap: .round,
                                                     lineJoin: .round))

                Arc(startAngle: self.minAngle,
                    endAngle: self.endAngle)
                    .strokeBorder(AngularGradient(gradient: Gradient(colors: [self.color,
                                                                              self.color.opacity(0.67)]),
                                                  center: .center,
                                                  startAngle: .degrees(180),
                                                  endAngle: .degrees(360)),
                                  style: StrokeStyle(lineWidth: lineWidth,
                                                     lineCap: .round,
                                                     lineJoin: .round))
            }
        }
    }
}

// MARK: - Preview

struct ArcView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ArcView(color: .pink,
                    progress: 0.3)
                .frame(width: 300)
        }
    }
}
