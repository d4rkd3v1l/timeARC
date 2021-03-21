//
//  SettingsWeekDaysPicker.swift
//  timeARC
//
//  Created by d4Rk on 21.03.21.
//

import SwiftUI

struct SettingsWeekDaysPicker: View {
    @Binding var selections: [WeekDay]

    var body: some View {
        Form {
            List {
                ForEach(WeekDay.allCases.sorted()) { weekDay in
                    MultipleSelectionRow(title: weekDay.symbol, isSelected: self.selections.contains(weekDay)) {
                        if self.selections.contains(weekDay) {
                            self.selections.removeAll(where: { $0 == weekDay })
                        }
                        else {
                            self.selections.append(weekDay)
                        }
                    }
                }
            }
        }
    }
}

private struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.title)
                    .foregroundColor(.primary)
                Spacer()

                if self.isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}
