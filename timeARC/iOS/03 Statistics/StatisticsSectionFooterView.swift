//
//  StatisticsSectionFooterView.swift
//  timeARC
//
//  Created by d4Rk on 12.02.21.
//

import SwiftUI

struct StatisticsSectionFooterView: View {
    let total: String
    let description: LocalizedStringKey

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 0) {
                Text("total")
                Text(": " + self.total)
                Spacer()
            }

            Text(self.description)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
