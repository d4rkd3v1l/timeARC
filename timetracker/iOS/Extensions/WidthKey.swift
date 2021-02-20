//
//  SetWidthKeyModifier.swift
//  timeARC
//
//  Created by d4Rk on 19.02.21.
//

import SwiftUI

struct SetWidthKeyModifier: ViewModifier {
    let index: Int

    func body(content: Content) -> some View {
        content
            .background(GeometryReader { proxy in
                Color.clear
                    .preference(key: WidthKey.self, value: [self.index: proxy.size.width])
            })
    }
}

extension View {
    func setWidthKey(index: Int) -> some View {
        self.modifier(SetWidthKeyModifier(index: index))
    }
}

struct WidthKey: PreferenceKey {
    typealias Value = [Int: CGFloat]

    static var defaultValue: Value = [:]

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue(), uniquingKeysWith: max)
    }
}
