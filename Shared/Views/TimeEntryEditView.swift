//
//  TimeEntryEditView.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 20.09.20.
//

import SwiftUI

struct TimeEntryEditView: View {
    let timeEntry: TimeEntry
    let onDismiss: ((TimeEntry) -> Void)?

    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var isRunning: Bool = false

    var body: some View {
        HStack {
            DatePickerView(date: self.$startDate)
                .onChange(of: self.startDate) { startDate in
                    if startDate > self.endDate {
                        self.startDate = self.endDate
                    }
                }

            Image(systemName: "arrow.right")

            if self.isRunning {
                StopTimerView(isRunning: self.$isRunning, date: self.$endDate)
            } else {
                DatePickerView(date: self.$endDate)
                    .onChange(of: self.endDate) { endDate in
                        if endDate < self.startDate {
                            self.endDate = self.startDate
                        }
                    }
            }
        }
        .frame(maxWidth: 400)
        .padding(.all, 15)
        .background(Color.secondaryGray)
        .cornerRadius(20)
        .onAppear {
            self.startDate = self.timeEntry.start
            self.endDate = self.timeEntry.end ?? Date()
            self.isRunning = self.timeEntry.isRunning
        }
        .onDisappear {
            var newTimeEntry = self.timeEntry
            newTimeEntry.start = self.startDate
            newTimeEntry.end = self.isRunning ? nil : self.endDate
            self.onDismiss?(newTimeEntry)
        }
    }

    struct DatePickerView: View {
        @Binding var date: Date

        var body: some View {
            DatePicker("", selection: self.$date, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .frame(minWidth: 140)
                .background(Color.primaryGray)
                .cornerRadius(10)
                .clipped()
                .environment(\.locale, Locale(identifier: "de")) // TODO: Remove
        }
    }

    struct StopTimerView: View {
        @Binding var isRunning: Bool
        @Binding var date: Date

        var body: some View {
            VStack {
                Text("This timer is currently running.")
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing, .bottom], 20)
                Button(action: {
                    self.date = Date()
                    self.isRunning.toggle()
                }) {
                    Text("stop")
                        .frame(width: 120, height: 40, alignment: .center)
                        .font(Font.body.bold())
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(20)
                }
            }
            .frame(width: 140, height: .infinity, alignment: .center)
        }
    }
}

struct TimeEntryEditViewPresenter: View {
    let timeEntry: TimeEntry

    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial), intensity: 1)
                .edgesIgnoringSafeArea(.all)

            TimeEntryEditView(timeEntry: timeEntry) { timeEntry in
                store.dispatch(action: UpdateTimeEntry(id: timeEntry.id, start: timeEntry.start, end: timeEntry.end))
            }
        }
    }
}
