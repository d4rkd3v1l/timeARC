//
//  StatisticsSectionModifier.swift
//  timeARC
//
//  Created by d4Rk on 12.02.21.
//

import SwiftUI

struct StatisticsSectionHeaderView: View {
    let imageName: String
    let title: LocalizedStringKey

    var body: some View {
        HStack {
            Image(systemName: self.imageName)
            Text(self.title)
                .font(.headline)
            Spacer()
        }
    }
}
