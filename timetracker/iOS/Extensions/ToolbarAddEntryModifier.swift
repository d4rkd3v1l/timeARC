//
//  ToolbarAddEntryModifier.swift
//  timeARC
//
//  Created by d4Rk on 19.02.21.
//

import SwiftUI
import SwiftUIFlux

struct ToolbarAddEntryModifier: ViewModifier {
    enum ActiveSheet: Identifiable {
        case addTimeEntry
        case addAbsenceEntry

        var id: Int {
            self.hashValue
        }
    }

    @EnvironmentObject var store: Store<AppState>
    @State private var activeSheet: ActiveSheet?

    let initialDay: Day
    let accentColor: Color

    func body(content: Content) -> some View {
        content
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: {
                            self.activeSheet = .addTimeEntry
                        }, label: {
                            Label("timeEntry", systemImage: "clock.fill")
                        })

                        Button(action: {
                            self.activeSheet = .addAbsenceEntry
                        }, label: {
                            Label("absenceEntry", systemImage: "calendar")
                        })
                    }
                    label: {
                        Image(systemName: "plus")
                    }
                }
            })
            .sheet(item: self.$activeSheet) { activeSheet in
                switch activeSheet {
                case .addTimeEntry:
                    NavigationView {
                        ListTimeEntryCreateView(initialDay: self.initialDay)
                            .environmentObject(self.store)
                            .accentColor(self.accentColor)
                    }

                case .addAbsenceEntry:
                    NavigationView {
                        ListAbsenceEntryCreateView(initialDay: self.initialDay)
                            .environmentObject(self.store)
                            .accentColor(self.accentColor)
                    }
                }
            }
    }
}

extension View {
    func toolbarAddEntry(initialDay: Day, accentColor: Color) -> some View {
        self.modifier(ToolbarAddEntryModifier(initialDay: initialDay, accentColor: accentColor))
    }
}
