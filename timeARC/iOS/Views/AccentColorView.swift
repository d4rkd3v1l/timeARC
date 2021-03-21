//
//  AccentColorView.swift
//  timeARC
//
//  Created by d4Rk on 21.03.21.
//

import SwiftUI

struct AccentColorView: View {
    @Environment(\.colorScheme) var colorScheme

    let color: CodableColor
    let isSelected: Bool

    var body: some View {
        self.color.color
            .frame(width: 40, height: 40)
            .cornerRadius(10)
            .overlay(
                Image(systemName: self.isSelected ? "checkmark" : "")
                    .foregroundColor(self.color.contrastColor(for: self.colorScheme))
            )
    }
}
