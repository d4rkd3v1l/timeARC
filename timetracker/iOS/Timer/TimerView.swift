//
//  ContentView.swift
//  Shared
//
//  Created by d4Rk on 18.07.20.
//

import SwiftUI
import SwiftUIFlux
import Combine

struct TimerView: ConnectedView {
    enum Tab: Equatable {
        case today
        case week

        var title: LocalizedStringKey {
            switch self {
            case .today:    return "today"
            case .week:     return "week"
            }
        }
    }

    struct Props {
        let timeEntries: [TimeEntry]
        let timeEntriesWeek: [TimeEntry]
        let workingDuration: Int
        let workingWeekDaysCount: Int
        let displayMode: TimerDisplayMode
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(timeEntries: state.timeState.timeEntries.forDay(Day()),
                     timeEntriesWeek: state.timeState.timeEntries
                        .timeEntries(from: Date().firstOfWeek,
                                     to: Date().lastOfWeek)
                        .flatMap { $0.value },
                     workingDuration: state.settingsState.workingDuration,
                     workingWeekDaysCount: state.settingsState.workingWeekDays.count,
                     displayMode: state.timeState.displayMode)
    }

    @State private var mode: Tab = .today
    @State private var duration: Int?
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect().share()

    func body(props: Props) -> some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    Spacer()

                    TabView(selection: self.$mode) {
                        VStack {
                            TimerArcView(timeEntries: props.timeEntries,
                                    workingDuration: props.workingDuration,
                                    displayMode: props.displayMode,
                                    timer: self.timer)
                        }
                        .tag(Tab.today)

                        VStack {
                            TimerArcView(timeEntries: props.timeEntriesWeek,
                                    workingDuration: props.workingDuration * props.workingWeekDaysCount,
                                    displayMode: props.displayMode,
                                    timer: self.timer)
                        }
                        .tag(Tab.week)
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    .frame(width: geometry.size.width, height: geometry.size.width, alignment: .center)

                    Spacer()

                    Button(props.timeEntries.isTimerRunning ? "stop" : "start") {
                        store.dispatch(action: ToggleTimer())
                    }
                    .buttonStyle(CTAStyle())

                    Spacer()
                }
                .navigationBarTitle(self.mode.title)
            }
        }
    }
}

private struct TimerArcView: View {
    let timeEntries: [TimeEntry]
    let workingDuration: Int
    let displayMode: TimerDisplayMode
    let timer: Publishers.Share<Publishers.Autoconnect<Timer.TimerPublisher>>

    @State private var duration: Int?

    var body: some View {
        ArcViewFull(duration: self.duration ?? timeEntries.totalDurationInSeconds,
                    maxDuration: workingDuration,
                    color: timeEntries.isTimerRunning ? .accentColor : .gray,
                    displayMode: displayMode)
            .aspectRatio(contentMode: .fit)
            .padding(.all, 50)
            .contentShape(Circle())
            .onTapGesture {
                store.dispatch(action: ChangeTimerDisplayMode(displayMode: displayMode.next))
            }
            .onReceive(self.timer) { _ in
                self.duration = timeEntries.totalDurationInSeconds
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
                    .colorScheme(.dark)
            }
        }
    }
}
