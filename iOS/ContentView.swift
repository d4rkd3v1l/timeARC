//
//  ContentView.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import SwiftUI
import SwiftUIFlux
import WidgetKit

struct ContentView: ConnectedView {
    struct Props {
        let isAppStateLoading: Bool
        let accentColor: Color
    }
    
    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(isAppStateLoading: state.isAppStateLoading,
                     accentColor: state.settingsState.accentColor.color)
    }

    @ViewBuilder func body(props: Props) -> some View {
        if props.isAppStateLoading {
            VStack {
                ProgressView()
                Text("loading")
                    .padding(.all, 10)
            }
        } else {
            TabView {
                TimerView()
                    .tabItem {
                        Image(systemName: "clock.fill") // timer
                        Text("timer")
                    }
//                OverviewView()
//                    .tabItem {
//                        Image(systemName: "calendar")
//                        Text("calendar")
//                    }
                ListView()
                    .tabItem {
                        Image(systemName: "tray.full.fill") // equal.square.fill
                        Text("list")
                    }
                Text("Statistics")
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("statistics")
                    }
                SettingsView()
                    .tabItem {
                        Image(systemName: "wrench.fill") // gear
                        Text("settings")
                    }
            }
            .accentColor(props.accentColor)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                updateWidgetData(store.state)
            }
        }
    }
}

// MARK: - Preview

struct timetrackerApp_Previews: PreviewProvider {
    static var previews: some View {
        store.dispatch(action: InitFlux())
        return StoreProvider(store: store) {
            ContentView()
        }
    }
}
