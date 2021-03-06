//
//  CodableColor.swift
//  timeARC
//
//  Created by d4Rk on 03.09.20.
//

import SwiftUI

enum CodableColor: String, RawRepresentable, Codable, Equatable, Hashable {
    case black
    case blue
    case gray
    case green
    case orange
    case pink
    case primary
    case purple
    case red
    case white
    case yellow

    init(_ color: Color) {
        switch color {
        case .black:    self = .black
        case .blue:     self = .blue
        case .gray:     self = .gray
        case .green:    self = .green
        case .orange:   self = .orange
        case .pink:     self = .pink
        case .primary:  self = .primary
        case .purple:   self = .purple
        case .red:      self = .red
        case .white:    self = .white
        case .yellow:   self = .yellow
        default:        self = .primary
        }
    }

    /// Does not resolve `.primary`! Use `color(for:)` instead.
    var color: Color {
        switch self {
        case .black:    return .black
        case .blue:     return .blue
        case .gray:     return .gray
        case .green:    return .green
        case .orange:   return .orange
        case .pink:     return .pink
        case .primary:  return .primary
        case .purple:   return .purple
        case .red:      return .red
        case .white:    return .white
        case .yellow:   return .yellow
        }
    }

    func color(for colorScheme: ColorScheme) -> Color {
        switch self {
        case .primary:
            switch colorScheme {
            case .dark: return .white
            default:    return .black
            }
        default:        return self.color
        }
    }

    /// Returns a color that has high contrast to self, e.g. to distinguish text from background
    func contrastColor(for colorScheme: ColorScheme) -> Color {
        return self.color(for: colorScheme).isLight ? .black : .white
    }
}

// MARK: - Extensions

private extension Color {
    var isLight: Bool {
        return UIColor(self).isLight
    }
}

private extension UIColor {
    // https://stackoverflow.com/a/40062565/2019384
    var isLight: Bool {
        return self.brightness > 0.5
    }

    var brightness: CGFloat {
        var white: CGFloat = 0
        self.getWhite(&white, alpha: nil)
        return white
    }
}
