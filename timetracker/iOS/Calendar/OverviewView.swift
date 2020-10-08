//
//  OverviewView.swift
//  timetracker
//
//  Created by d4Rk on 20.07.20.
//

import SwiftUI
import SwiftUIFlux

struct OverviewView: ConnectedView {
    struct Props {
        let timeEntries: [TimeEntry]
        let workingWeekDays: [WeekDay]
        let workingMinutesPerDay: Int
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(timeEntries: state.timeState.timeEntries.values.flatMap { $0 },
                     workingWeekDays: state.settingsState.workingWeekDays,
                     workingMinutesPerDay: state.settingsState.workingMinutesPerDay)
    }

    private var year: DateInterval {
        calendar.dateInterval(of: .year, for: Date())!
    }

    @Environment(\.calendar) var calendar

    func body(props: Props) -> some View {
        NavigationView {
            CalendarView(interval: year) { date in
                Text("00")
                    .hidden()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 14)
                    .overlay(
                        NavigationLink(destination: EntryDetailsView(selectedDate: date)) {
                            let weekday = Calendar.current.component(.weekday, from: date)
                            let isWorkingDay = props.workingWeekDays.contains(WeekDay(weekday)) && date.startOfDay < Date()
                            let duration = props.timeEntries.totalDurationInSeconds
                            let desiredWorkMinutes = isWorkingDay ? props.workingMinutesPerDay : 0
                            let overtime = duration / 60 - desiredWorkMinutes
                            ZStack {
                                ArcView(color: isWorkingDay ? Color.accentColor : .gray, progress: Double(duration) / Double(props.workingMinutesPerDay * 60))
                                Text(String(self.calendar.component(.day, from: date)))
                                    .font(.system(size: 18)).bold()
                                    .foregroundColor(.primary)

                                if overtime != 0 {
                                Text("\(formattedOvertime(for: overtime))")
                                    .font(.system(size: 9)).bold()
                                    .foregroundColor(isWorkingDay ? Color.accentColor : .gray)
                                    .offset(x: 0, y: 17)
                                }
                            }
                        }
                    )
            }
            .navigationBarTitle("calendar")
        }
    }

    private func formattedOvertime(for duration: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.positivePrefix = numberFormatter.plusSign
        return numberFormatter.string(from: NSNumber(integerLiteral: duration)) ?? ""
    }
}

// MARK: - Preview

struct EntriesView_Previews: PreviewProvider {
    static var previews: some View {
        store.dispatch(action: InitFlux())

        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        store.dispatch(action: AddTimeEntry(timeEntry: TimeEntry(start: formatter.date(from: "01.01.2020 08:27")!, end: formatter.date(from: "01.01.2020 12:13")!)))
        store.dispatch(action: AddTimeEntry(timeEntry: TimeEntry(start: formatter.date(from: "01.01.2020 12:54")!, end: formatter.date(from: "01.01.2020 18:30")!)))

        store.dispatch(action: AddTimeEntry(timeEntry: TimeEntry(start: formatter.date(from: "04.01.2020 08:27")!, end: formatter.date(from: "04.01.2020 12:13")!)))

        return StoreProvider(store: store) {
            OverviewView()
                .accentColor(.green)
        }
    }
}
