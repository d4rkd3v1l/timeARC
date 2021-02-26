//
//  ContentView.swift
//  timeARC
//
//  Created by d4Rk on 20.07.20.
//

import SwiftUI
import SwiftUIFlux
import WidgetKit

struct ContentView: ConnectedView {
    @Environment(\.colorScheme) var colorScheme

    struct Props {
        let state: AppState
        let isAppStateLoading: Bool
        let accentColor: CodableColor
    }
    
    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(state: state,
                     isAppStateLoading: state.isAppStateLoading,
                     accentColor: state.settingsState.accentColor)
    }

    func body(props: Props) -> some View {
        Group {
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
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    updateWidgetData(props.state)
                }
                .accentColor(props.accentColor.color)
                .contrastColor(props.accentColor.contrastColor(for: self.colorScheme))
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(previewStore)
    }
}
#endif
