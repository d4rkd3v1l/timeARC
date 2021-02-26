//
//  AnimatableSystemFontModifier.swift
//  timeARC
//
//  Created by d4Rk on 10.09.20.
//

import SwiftUI

// https://www.hackingwithswift.com/quick-start/swiftui/how-to-animate-the-size-of-text
struct AnimatableSystemFontModifier: AnimatableModifier {
    var size: CGFloat
    var weight: Font.Weight
    var design: Font.Design

    var animatableData: CGFloat {
        get { self.size }
        set { self.size = newValue }
    }

    func body(content: Content) -> some View {
        content
            .font(.system(size: self.size, weight: self.weight, design: self.design))
    }
}

extension View {
    func animatableSystemFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        self.modifier(AnimatableSystemFontModifier(size: size, weight: weight, design: design))
    }
}
