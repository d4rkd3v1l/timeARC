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
        let displayMode: TimerDisplayMode
        let buttonTextColor: Color
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(timeEntries: state.timeState.timeEntries.forDay(Date()),
                     workingMinutesPerDay: state.settingsState.workingMinutesPerDay,
                     displayMode: state.timeState.displayMode,
                     buttonTextColor: state.settingsState.accentColor.contrastColor(for: self.colorScheme))
    }

    @State var duration: Int?
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    func body(props: Props) -> some View {
        VStack {
            Spacer()
            Spacer()
            ArcViewFull(duration: self.duration ?? props.timeEntries.totalDurationInSeconds,
                        maxDuration: props.workingMinutesPerDay * 60,
                        color: props.timeEntries.isTimerRunning ? .accentColor : .gray,
                        displayMode: props.displayMode)
                .aspectRatio(contentMode: .fit)
                .padding(.all, 50)
                .contentShape(Circle())
                .onTapGesture {
                    store.dispatch(action: ChangeTimerDisplayMode(displayMode: props.displayMode.next))
                }
                .onReceive(self.timer) { _ in
                    self.duration = props.timeEntries.totalDurationInSeconds
                }
            Button(action: {
                store.dispatch(action: ToggleTimer())
            }) {
                Text(props.timeEntries.isTimerRunning ? "stop" : "start")
                    .frame(width: 200, height: 50)
                    .font(Font.body.bold())
                    .foregroundColor(props.buttonTextColor)
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
