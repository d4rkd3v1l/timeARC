//
//  TimeEntryEditView.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 20.09.20.
//

import SwiftUI
import PartialSheet

struct TimeEntryEditView: View {
    let timeEntry: TimeEntry
    let title: LocalizedStringKey
    let buttonTitle: LocalizedStringKey
    let buttonTextColor: Color
    var onUpdate: ((TimeEntry) -> Void)? = nil

    @EnvironmentObject var partialSheetManager: PartialSheetManager
    @State private var day: Date = Date()
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var isRunning: Bool = false

    var body: some View {
        VStack {
            Text(self.title)
                .font(.headline)
            Form {
                VStack {
                    if self.isRunning {
                        Text("timerCurrentlyRunning")
                            .multilineTextAlignment(.center)
                            .padding(.all, 10)
                    }
                    HStack {
                        Text("date")
                        Spacer()
                        DatePicker("", selection: self.$day, displayedComponents: .date)
                            .labelsHidden()
                            .frame(alignment: .center)
                            .onChange(of: self.day) { day in
                                guard let newStartDate = self.startDate.withDate(from: day),
                                      let newEndDate = self.endDate.withDate(from: day) else { return }
                                self.startDate = newStartDate
                                self.endDate = newEndDate
                            }
                    }
                    HStack {
                        Text("time")
                        Spacer()
                        DatePicker("", selection: self.$startDate, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .onChange(of: self.startDate) { startDate in
                                if startDate > self.endDate {
                                    self.startDate = self.endDate
                                }
                            }
                        Image(systemName: "arrow.right")
                        if self.isRunning {
                            VStack {
                                Button(action: {
                                    self.endDate = Date()
                                    self.isRunning.toggle()
                                }) {
                                    Text("stop")
                                        .frame(width: 120, height: 34, alignment: .center)
                                        .font(Font.body.bold())
                                        .foregroundColor(self.buttonTextColor)
                                        .background(Color.accentColor)
                                        .cornerRadius(17)
                                }
                            }
                        } else {
                            DatePicker("", selection: self.$endDate, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .onChange(of: self.endDate) { endDate in
                                    if endDate < self.startDate {
                                        self.endDate = self.startDate
                                    }
                                }
                        }
                    }
                }
            }
            Button(action: {
                var newTimeEntry = self.timeEntry
                newTimeEntry.start = self.startDate
                newTimeEntry.end = self.isRunning ? nil : self.endDate
                self.onUpdate?(newTimeEntry)

                withAnimation {
                    self.partialSheetManager.closePartialSheet()
                }
            }) {
                Text(self.buttonTitle)
                    .frame(width: 200, height: 50)
                    .font(Font.body.bold())
                    .foregroundColor(self.buttonTextColor)
                    .background(Color.accentColor)
                    .cornerRadius(25)
            }
        }
        .frame(maxHeight: self.isRunning ? 300 : 250)
        .onAppear {
            self.day = self.startDate.startOfDay
            self.startDate = self.timeEntry.start
            self.endDate = self.timeEntry.end ?? Date()
            self.isRunning = self.timeEntry.isRunning
        }
    }
}

struct TimeEntryEditView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            TimeEntryEditView(timeEntry: TimeEntry(start: Date(), end: Date()),
                              title: "addEntryTitle",
                              buttonTitle: "add",
                              buttonTextColor: .white)
            Spacer()
            TimeEntryEditView(timeEntry: TimeEntry(start: Date(), end: nil),
                              title: "updateEntryTitle",
                              buttonTitle: "update",
                              buttonTextColor: .white)
            Spacer()
        }
        .accentColor(.green)
        .environment(\.colorScheme, .dark)
        .background(Color.primary)
    }
}
