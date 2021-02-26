//
//  CTAStyle.swift
//  timeARC
//
//  Created by d4Rk on 29.11.20.
//

import SwiftUI

struct CTAStyle: ButtonStyle {
    enum Size {
        case small
        case large

        var width: CGFloat {
            switch self {
            case .small: return 120
            case .large: return 200
            }
        }

        var height: CGFloat {
            switch self {
            case .small: return 34
            case .large: return 50
            }
        }
    }

    let size: Size

    init(_ size: Size = .large) {
        self.size = size
    }

    func makeBody(configuration: Configuration) -> some View {
        Rectangle()
            .fill(Color.accentColor)
            .overlay(configuration.label.foregroundColor(Color.contrastColor))
            .font(Font.body.bold())
            .frame(width: self.size.width, height: self.size.height)
            .cornerRadius(self.size.height / 2)
    }
}
