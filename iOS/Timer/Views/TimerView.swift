//
//  ContentView.swift
//  Shared
//
//  Created by d4Rk on 18.07.20.
//

import SwiftUI
import SwiftUIFlux

struct TimerView: ConnectedView {
    @Environment(\.colorScheme) var colorScheme

    struct Props {
        let timeEntries: [TimeEntry]
        let workingMinutesPerDay: Int
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(timeEntries: state.timeState.timeEntries,
                     workingMinutesPerDay: state.settingsState.workingMinutesPerDay)
    }

    @State var duration: Int = 0
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    func body(props: Props) -> some View {
        VStack {
            Spacer()
            Spacer()
            ArcViewFull(duration: self.duration,
                        maxDuration: props.workingMinutesPerDay * 60,
                        color: props.timeEntries.isTimerRunning ? .accentColor : .gray)
                .aspectRatio(contentMode: .fit)
                .padding(.all, 50)
                .onReceive(self.timer) { _ in
                    self.duration = props.timeEntries.totalDurationInSeconds(on: Date())
                }
            Button(action: {
                store.dispatch(action: ToggleTimer())
            }) {
                Text(LocalizedStringKey(props.timeEntries.isTimerRunning ? "Stop" : "Start"))
                    .frame(width: 200, height: 50)
                    .font(Font.body.bold())
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(25)
            }
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Preview

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        store.dispatch(action: InitFlux())
        return Group {
            StoreProvider(store: store) {
                TimerView()
                    .accentColor(.green)
            }
        }
    }
}
