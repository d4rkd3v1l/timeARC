//
//  CodableColor.swift
//  timetracker
//
//  Created by d4Rk on 03.09.20.
//

import SwiftUI

struct CodableColor: Codable, Hashable, Equatable {
    private let _color: String

    static var black = CodableColor(.black)
    static var blue = CodableColor(.blue)
    static var gray = CodableColor(.gray)
    static var green = CodableColor(.green)
    static var orange = CodableColor(.orange)
    static var pink = CodableColor(.pink)
    static var primary = CodableColor(.primary)
    static var purple = CodableColor(.purple)
    static var red = CodableColor(.red)
    static var white = CodableColor(.white)
    static var yellow = CodableColor(.yellow)

    init(_ color: Color) {
        switch color {
        case .black:    self._color = "black"
        case .blue:     self._color = "blue"
        case .gray:     self._color = "gray"
        case .green:    self._color = "green"
        case .orange:   self._color = "orange"
        case .pink:     self._color = "pink"
        case .primary:  self._color = "primary"
        case .purple:   self._color = "purple"
        case .red:      self._color = "red"
        case .white:    self._color = "white"
        case .yellow:   self._color = "yellow"
        default:        self._color = "primary"
        }
    }

    /// Does not resolve `.primary`! Use `color(for:)` instead.
    var color: Color {
        switch self._color {
        case "black":   return .black
        case "blue":    return .blue
        case "gray":    return .gray
        case "green":   return .green
        case "orange":  return .orange
        case "pink":    return .pink
        case "primary": return .primary
        case "purple":  return .purple
        case "red":     return .red
        case "white":   return .white
        case "yellow":  return .yellow
        default:        return .primary
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
