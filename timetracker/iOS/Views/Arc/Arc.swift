//
//  Arc.swift
//  timeARC
//
//  Created by d4Rk on 30.01.21.
//

import SwiftUI

// https://www.hackingwithswift.com/books/ios-swiftui/adding-strokeborder-support-with-insettableshape
struct Arc: InsettableShape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool = true
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let rotationAdjustment = Angle.degrees(215)
        let modifiedStart = self.startAngle - rotationAdjustment
        let modifiedEnd = self.endAngle - rotationAdjustment

        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: rect.width / 2 - self.insetAmount,
                    startAngle: modifiedStart,
                    endAngle: modifiedEnd,
                    clockwise: !self.clockwise)

        return path
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
}
