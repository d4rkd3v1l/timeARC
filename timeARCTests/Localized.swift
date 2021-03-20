//
//  Localized.swift
//  timeARC
//
//  Created by d4Rk on 20.03.21.
//

import XCTest

protocol Localized {
    static func localized(en: Self, de: Self) throws -> Self
}

extension Localized {
    static func localized(en: Self, de: Self) throws -> Self {

        switch Locale.current.identifier {
        case "en_US":   return en
        case "de_DE":   return de
        default:        throw XCTSkip("Invalid locale for this test.")

        }
    }
}

extension String: Localized {}
extension Int: Localized {}
extension Date: Localized {}
extension Array: Localized where Element: Localized {}
