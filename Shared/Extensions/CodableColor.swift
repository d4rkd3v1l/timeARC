//
//  CodableColor.swift
//  timetracker
//
//  Created by d4Rk on 03.09.20.
//

import SwiftUI

struct CodableColor: Codable {
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

    /// Returns a color that has high contrast to self, e.g. to distinguish text from background
    func contrastColor(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .light:
            return self._color == "primary" ? .white : .primary

        case .dark:
            return self._color == "primary" ? .black : .primary

        @unknown default:
            return .primary
        }
    }
}
