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
        let timeEntries: [TimeEntry]
        let workingMinutesPerDay: Int
        let accentColor: Color
        let buttonTextColor: Color
    }

    func map(state: WatchState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(timeEntries: state.timeEntries,
                     workingMinutesPerDay: state.workingMinutesPerDay,
                     accentColor: state.accentColor.color,
                     buttonTextColor: state.accentColor.contrastColor(for: self.colorScheme))
    }

    @State var duration: Int = 0
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    func body(props: Props) -> some View {
        VStack {
//            Spacer()
            ArcViewFull(duration: self.duration,
                        maxDuration: props.workingMinutesPerDay * 60,
                        color: props.timeEntries.isTimerRunning ? .accentColor : .gray)
                .frame(width: self.arcSize, height: self.arcSize)
                .onReceive(self.timer) { _ in
                    self.duration = props.timeEntries.totalDurationInSeconds(on: Date())
                }
//            Spacer()
            Button(action: {
                store.dispatch(action: ToggleTimer())
            }) {
                Text(LocalizedStringKey(props.timeEntries.isTimerRunning ? "Stop" : "Start"))
                    .frame(maxWidth: .infinity)
                    .frame(height: WatchHelper.buttonHeight)
                    .font(Font.body.bold())
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(WatchHelper.buttonHeight / 2)
            }
            .buttonStyle(PlainButtonStyle())
//            Spacer()
        }
        .accentColor(props.accentColor)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
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
