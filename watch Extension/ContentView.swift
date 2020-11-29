//
//  ContentView.swift
//  watch Extension
//
//  Created by d4Rk on 23.08.20.
//

import SwiftUI
import SwiftUIFlux

struct ContentView: ConnectedView {
    @Environment(\.colorScheme) var colorScheme

    struct Props {
        let isWatchStateLoading: Bool
        let timeEntries: [TimeEntry]
        let displayMode: TimerDisplayMode
        let workingDuration: Int
        let accentColor: Color
    }

    func map(state: WatchState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(isWatchStateLoading: state.isWatchStateLoading,
                     timeEntries: state.timeEntries,
                     displayMode: state.displayMode,
                     workingDuration: state.workingDuration,
                     accentColor: state.accentColor.color)
    }

    @State var duration: Int?
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    @ViewBuilder func body(props: Props) -> some View {
        if props.isWatchStateLoading {
            VStack {
                ProgressView()
                Text("loading")
            }
        } else {
            VStack {
                ArcViewFull(duration: self.duration ?? props.timeEntries.totalDurationInSeconds,
                            maxDuration: props.workingDuration,
                            color: props.timeEntries.isTimerRunning ? .accentColor : .gray,
                            displayMode: props.displayMode)
                    .frame(width: self.arcSize, height: self.arcSize)
                    .onTapGesture {
                        store.dispatch(action: ChangeTimerDisplayMode(displayMode: props.displayMode.next))
                    }
                    .onReceive(self.timer) { _ in
                        self.duration = props.timeEntries.totalDurationInSeconds
                    }
                Button(action: {
                    store.dispatch(action: ToggleTimer())
                }) {
                    Text(props.timeEntries.isTimerRunning ? "Stop" : "Start")
                        .frame(maxWidth: .infinity)
                        .frame(height: WatchHelper.buttonHeight)
                        .font(Font.body.bold())
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(WatchHelper.buttonHeight / 2)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .accentColor(props.accentColor)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
        }
    }

    private var arcSize: CGFloat {
        return WKInterfaceDevice.current().screenBounds.size.height * 0.53
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .accentColor(.green)
    }
}
