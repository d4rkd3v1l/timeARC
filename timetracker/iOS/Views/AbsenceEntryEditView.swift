//
//  AbsenceEntryEditView.swift
//  timetracker
//
//  Created by d4Rk on 10.10.20.
//

import SwiftUI
import PartialSheet

struct AbsenceEntryEditView: View {
    let absenceEntry: AbsenceEntry
    let absenceTypes: [AbsenceType]
    let title: LocalizedStringKey
    let buttonTitle: LocalizedStringKey
    var onUpdate: ((AbsenceEntry) -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    @EnvironmentObject var partialSheetManager: PartialSheetManager
    @State private var absenceType: AbsenceType = .dummy
    @State private var startDay: Day = Day()
    @State private var endDay: Day = Day()
    @State private var isAbsenceTypeExpanded: Bool = false

    var body: some View {
        let startDayBinding = Binding<Date>(
            get: { self.startDay.date },
            set: { self.startDay = $0.day }
        )

        let endDayBinding = Binding<Date>(
            get: { self.endDay.date },
            set: { self.endDay = $0.day }
        )

        return ZStack {
            VStack {
                Text(self.title)
                    .font(.headline)
                    .padding()
                Form {
                    DisclosureGroup(
                        isExpanded: self.$isAbsenceTypeExpanded,
                        content: {
                            SingleValuePickerView(availableItems: self.absenceTypes,
                                                  selection: self.absenceType)
                                .onSelectionChange { newSelection in
                                    self.absenceType = newSelection
                                }
                        },
                        label: {
                            HStack {
                                Text("absenceType")
                                Spacer()
                                Text(LocalizedStringKey(self.absenceType.title))
                                Text(self.absenceType.icon)
                            }
                        }
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            self.isAbsenceTypeExpanded.toggle()
                        }
                    }

                    HStack {
                        DatePicker("", selection: startDayBinding, displayedComponents: .date)
                            .labelsHidden()
                            .onChange(of: self.startDay) { startDay in
                                if startDay > self.endDay {
                                    self.startDay = self.endDay
                                }
                            }
                        Image(systemName: "arrow.right")
                        DatePicker("", selection: endDayBinding, displayedComponents: .date)
                            .labelsHidden()
                            .onChange(of: self.endDay) { endDate in
                                if endDay < self.startDay {
                                    self.endDay = self.startDay
                                }
                            }
                    }
                }

                Button(self.buttonTitle) {
                    var newAbsenceEntry = self.absenceEntry
                    newAbsenceEntry.update(type: self.absenceType,
                                           start: self.startDay,
                                           end: self.endDay)
                    self.onUpdate?(newAbsenceEntry)

                    withAnimation {
                        self.partialSheetManager.closePartialSheet()
                    }
                }
                .buttonStyle(CTAStyle())
            }
            .onAppear {
                self.absenceType = self.absenceEntry.type
                self.startDay = self.absenceEntry.start
                self.endDay = self.absenceEntry.end
            }

            if let onDelete = self.onDelete {
                HStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            onDelete()

                            withAnimation {
                                self.partialSheetManager.closePartialSheet()
                            }
                        }) {
                            Image(systemName: "trash.fill").imageScale(.large)
                        }
                        .padding()
                        Spacer()
                    }
                }
            }
        }
        // TODO: Fix this! This leads to absence type only being tappable after scrolling
//        .frame(maxHeight: self.isAbsenceTypeExpanded ? 600 : 300)
        .frame(maxHeight: 700)
    }
}

struct AbsenceEntryEditView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            AbsenceEntryEditView(absenceEntry: AbsenceEntry(type: AbsenceType(id: UUID(),
                                                                              title: "bankHoliday",
                                                                              icon: "🙌",
                                                                              offPercentage: 1),
                                                            start: Day(),
                                                            end: Day().addingDays(2)),
                                 absenceTypes: SettingsState().absenceTypes,
                                 title: "addAbsenceEntry",
                                 buttonTitle: "add",
                                 onUpdate: { _ in },
                                 onDelete: {})
            Spacer()
        }
        .accentColor(.green)
        .environment(\.colorScheme, .dark)
        .background(Color.primary)
    }
}
