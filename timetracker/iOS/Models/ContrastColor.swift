//
//  ContrastColor.swift
//  timetracker
//
//  Created by d4Rk on 29.11.20.
//

import SwiftUI

private var _contrastColor: Color = .black

extension Color {
    static var contrastColor: Color {
        return _contrastColor
    }
}

// MARK: - Environment

private struct ContrastColorKey: EnvironmentKey {
    static let defaultValue: Color = .white
}

extension EnvironmentValues {
    var contrastColor: Color {
        get {
            self[ContrastColorKey.self]
        }
        set {
            self[ContrastColorKey.self] = newValue
            _contrastColor = newValue
        }
    }
}

extension View {
    func contrastColor(_ color: Color) -> some View {
        self.environment(\.contrastColor, color)
    }
}
