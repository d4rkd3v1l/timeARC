//
//  ContentView.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import SwiftUI
import SwiftUIFlux
import WidgetKit
import PartialSheet

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
                ListView()
                    .tabItem {
                        Image(systemName: "tray.full.fill") // equal.square.fill
                        Text("list")
                    }
                StatisticsView()
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
            .addPartialSheet(style: PartialSheetStyle(background: .solid(Color(UIColor.systemGroupedBackground)),
                                                      handlerBarColor: Color.primary,
                                                      enableCover: true,
                                                      coverColor: Color(UIColor.secondarySystemBackground).opacity(0.7),
                                                      blurEffectStyle: nil,
                                                      cornerRadius: 15,
                                                      minTopDistance: 0))
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                updateWidgetData(store.state)
            }
            .accentColor(props.accentColor)
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
