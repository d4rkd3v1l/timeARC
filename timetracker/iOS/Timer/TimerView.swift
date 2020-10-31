//
//  ContentView.swift
//  Shared
//
//  Created by d4Rk on 18.07.20.
//

import SwiftUI
import SwiftUIFlux
import Introspect
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
        let workingMinutesPerDay: Int
        let workingWeekDaysCount: Int
        let displayMode: TimerDisplayMode
        let buttonTextColor: Color
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(timeEntries: state.timeState.timeEntries.forDay(Day()),
                     timeEntriesWeek: state.timeState.timeEntries.forCurrentWeek().flatMap { $0.value },
                     workingMinutesPerDay: state.settingsState.workingMinutesPerDay,
                     workingWeekDaysCount: state.settingsState.workingWeekDays.count,
                     displayMode: state.timeState.displayMode,
                     buttonTextColor: state.settingsState.accentColor.contrastColor(for: self.colorScheme))
    }

    @Environment(\.colorScheme) var colorScheme
    @State private var mode: Tab = .today
    @State private var duration: Int?
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect().share()

    func body(props: Props) -> some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    Spacer()

                    TabView(selection: self.$mode) {
                        VStack {
                            BlaView(timeEntries: props.timeEntries,
                                    workingMinutesPerDay: props.workingMinutesPerDay,
                                    displayMode: props.displayMode,
                                    timer: self.timer)
                        }
                        .tag(Tab.today)

                        VStack {
                            BlaView(timeEntries: props.timeEntriesWeek,
                                    workingMinutesPerDay: props.workingMinutesPerDay * props.workingWeekDaysCount,
                                    displayMode: props.displayMode,
                                    timer: self.timer)
                        }
                        .tag(Tab.week)
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    .frame(width: geometry.size.width, height: geometry.size.width, alignment: .center)
                    .background(CodableColor.primary.contrastColor(for: self.colorScheme))

                    Spacer()

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
                }
                .navigationBarTitle(self.mode.title)
            }
        }
    }
}

private struct BlaView: View {
    let timeEntries: [TimeEntry]
    let workingMinutesPerDay: Int
    let displayMode: TimerDisplayMode
    let timer: Publishers.Share<Publishers.Autoconnect<Timer.TimerPublisher>>

    @State private var duration: Int?

    var body: some View {
        ArcViewFull(duration: self.duration ?? timeEntries.totalDurationInSeconds,
                    maxDuration: workingMinutesPerDay * 60,
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
            }
        }
    }
}
