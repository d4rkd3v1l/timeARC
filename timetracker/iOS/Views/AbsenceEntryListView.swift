//
//  AbsenceEntryListView.swift
//  timetracker
//
//  Created by d4Rk on 10.10.20.
//

import SwiftUI

struct AbsenceEntryListView: View {
    let absenceEntry: AbsenceEntry

    var body: some View {
        HStack {
            Spacer()
            Text(LocalizedStringKey(self.absenceEntry.type.title))
            Text(self.absenceEntry.type.icon)
            Spacer()
        }
    }
}
