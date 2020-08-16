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
        let workingHoursPerDay: Int
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(workingWeekDays: state.settingsState.workingWeekDays,
                     workingHoursPerDay: state.settingsState.workingHoursPerDay)
    }

    @State var workingHoursPerDay: Int = 0

    func body(props: Props) -> some View {
        Form {
            Picker(selection: self.$workingHoursPerDay, label: Text("Picker")) {
                Text("1").tag(1)
                Text("2").tag(2)
                Text("3").tag(3)
            }
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

