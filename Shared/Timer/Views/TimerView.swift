//
//  ContentView.swift
//  Shared
//
//  Created by d4Rk on 18.07.20.
//

import SwiftUI
import SwiftUIFlux

struct TimerView: ConnectedView {
    struct Props {
        let timeEntries: [TimeEntry]
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(timeEntries: state.timeState.timeEntries)
    }

    @State var duration: Int = 0
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    func body(props: Props) -> some View {
        VStack {
            Spacer()
            Spacer()
            ZStack {
                ArcView(color: Color.accentColor, progress: (Double(self.duration) / Double(28800)))
                Text("\(self.duration / 288)%")
                    .font(.system(size: 60)).bold()

                Text(self.duration.formatted(allowedUnits: [.hour, .minute, .second]) ?? "")
                    .font(.system(size: 28)).bold()
                    .offset(x: 0, y: 100)
            }
            .frame(width: 250, height: 250)
            .onReceive(self.timer) { _ in
                self.duration = props.timeEntries.totalDurationInSeconds(on: Date())
            }
            Spacer()
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
