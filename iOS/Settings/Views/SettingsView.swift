//
//  SettingsView.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 14.08.20.
//

import SwiftUI
import SwiftUIFlux

struct SettingsView: ConnectedView {
    struct Props {
        let workingWeekDays: [WeekDay]
        let workingMinutesPerDay: Int
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(workingWeekDays: state.settingsState.workingWeekDays,
                     workingMinutesPerDay: state.settingsState.workingMinutesPerDay)
    }

    @State private var workingHours: Date = Date().startOfDay.addingTimeInterval(28800)

    func body(props: Props) -> some View {
        NavigationView {
            Form {
                DatePicker("Working hours", selection: self.$workingHours, displayedComponents: .hourAndMinute)
                NavigationLink(
                    destination: MultipleValuesPickerView(title: "Week days",
                                                          sectionHeader: "Choose your working days",
                                                          initial: props.workingWeekDays)
                        .onSelectionChange { newSelections in
                            store.dispatch(action: UpdateWorkingWeekDays(workingWeekDays: newSelections))
                        }
                ) {
                    HStack {
                        Text("Week days")
                        Spacer()
                        Text("\(props.workingWeekDays.count)") // sorted().map { $0.shortSymbol }.joined(separator: ", ")
                    }
                    .onAppear {}
                }
            }
            .navigationBarTitle("Settings")
        }
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        store.dispatch(action: InitFlux())
        return Group {
            StoreProvider(store: store) {
                NavigationView {
                    SettingsView()
                        .accentColor(.green)
                }
            }
        }
    }
}

