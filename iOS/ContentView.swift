//
//  ContentView.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import SwiftUI
import SwiftUIFlux
import WidgetKit

struct ContentView: View {
    var body: some View {
        TabView {
            TimerView()
                .tabItem {
                    Image(systemName: "clock.fill") // timer
                    Text(LocalizedStringKey("Timer"))
                }
            OverviewView()
                .tabItem {
                    Image(systemName: "equal.square.fill") // calendar, text.justify
                    Text(LocalizedStringKey("Overview"))
                }
            Text("Statistics")
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text(LocalizedStringKey("Statistics"))
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "wrench.fill") // gear
                    Text(LocalizedStringKey("Settings"))
                }
        }
        .accentColor(.green)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            updateWidgetData(store.state)
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
