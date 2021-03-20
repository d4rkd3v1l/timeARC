//
//  XCTestCase+localizedString.swift
//  timeARCUITests
//
//  Created by d4Rk on 19.03.21.
//

import XCTest

extension XCTestCase {
    func localizedString(_ key: String) -> String {
        let bundle = Bundle(for: Self.self)
        let deviceLanguage = Locale.preferredLanguages[0]
        let localizationBundle = Bundle(path: bundle.path(forResource: deviceLanguage, ofType: "lproj")!)
        let result = NSLocalizedString(key, bundle:localizationBundle!, comment: "")
        return result
    }
}
