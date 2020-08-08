//
//  OverviewView.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import SwiftUI
import SwiftUIFlux

struct OverviewView: ConnectedView {
    @Environment(\.calendar) var calendar
    @State(initialValue: "") var selectedDate: String

    struct Props {
        let timeEntries: [TimeEntry]
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(timeEntries: state.timeState.timeEntries)
    }

    private var year: DateInterval {
        calendar.dateInterval(of: .year, for: Date())!
    }

    func body(props: Props) -> some View {
        NavigationView {
            CalendarView(interval: year) { date in
                Text("00")
                    .hidden()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 16)
                    .overlay(
                        NavigationLink(destination: EntryDetailsView(selectedDate: date)) {
                            ZStack {
                            ArcView(color: Color.accentColor, progress: Double(props.timeEntries.totalDurationInSeconds(on: date)) / Double(28800))
                            Text(String(self.calendar.component(.day, from: date)))
                                .font(.system(size: 18)).bold()
                                .foregroundColor(.black)

                            Text("\(Int.random(in: -10...30))")
                                .font(.system(size: 10)).bold()
                                .foregroundColor(Color.accentColor)
                                .offset(x: 0, y: 17)
                            }
                        }
                    )
            }.navigationBarTitle("Overview")
        }
    }
}

// MARK: - Preview

struct EntriesView_Previews: PreviewProvider {
    static var previews: some View {
        store.dispatch(action: InitFlux())
        store.dispatch(action: ToggleTimer())
        return StoreProvider(store: store) {
            OverviewView()
                .accentColor(.green)
        }
    }
}
