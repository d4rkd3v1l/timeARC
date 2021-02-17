//
//  TimeEntryEditView.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 20.09.20.
//

import SwiftUI

struct TimeEntryEditView: View {
    let timeEntry: TimeEntry
    let title: LocalizedStringKey
    let buttonTitle: LocalizedStringKey
    var onUpdate: ((TimeEntry) -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    @Environment(\.contrastColor) var contrastColor
    @State private var day: Day = Day()
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var isRunning: Bool = false

    var body: some View {
        let dayBinding = Binding<Date>(
            get: { self.day.date },
            set: { self.day = $0.day }
        )

        return ZStack {
            VStack {
                Text(self.title)
                    .font(.headline)
                    .padding()
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
                            DatePicker("", selection: dayBinding, displayedComponents: .date)
                                .labelsHidden()
                                .frame(alignment: .center)
                                .onChange(of: self.day) { day in
                                    guard let newStartDate = self.startDate.withDate(from: day.date),
                                          let newEndDate = self.endDate.withDate(from: day.date) else { return }
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
                                    Button("stop") {
                                        self.endDate = Date()
                                        self.isRunning.toggle()
                                    }
                                    .buttonStyle(CTAStyle(.small))
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
                Button(self.buttonTitle) {
                    var newTimeEntry = self.timeEntry
                    newTimeEntry.start = self.startDate
                    newTimeEntry.end = self.isRunning ? nil : self.endDate
                    self.onUpdate?(newTimeEntry)

//                    withAnimation {
//                        self.partialSheetManager.closePartialSheet()
//                    }
                }
                .buttonStyle(CTAStyle())
            }
            .onAppear {
                self.day = self.startDate.day
                self.startDate = self.timeEntry.start
                self.endDate = self.timeEntry.end ?? Date()
                self.isRunning = self.timeEntry.isRunning
            }

            if let onDelete = self.onDelete {
                HStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            onDelete()

//                            withAnimation {
//                                self.partialSheetManager.closePartialSheet()
//                            }
                        }) {
                            Image(systemName: "trash.fill").imageScale(.large)
                        }
                        .padding()
                        Spacer()
                    }
                }
            }
        }
        .frame(maxHeight: self.isRunning ? 350 : 300)
    }
}

struct TimeEntryEditView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            TimeEntryEditView(timeEntry: TimeEntry(start: Date(), end: Date()),
                              title: "addEntryTitle",
                              buttonTitle: "add")
            Spacer()
            TimeEntryEditView(timeEntry: TimeEntry(start: Date(), end: nil),
                              title: "updateEntryTitle",
                              buttonTitle: "update",
                              onUpdate: { _ in },
                              onDelete: {})
            Spacer()
        }
        .accentColor(.green)
        .environment(\.colorScheme, .dark)
        .background(Color.primary)
    }
}
