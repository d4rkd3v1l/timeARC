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
    let buttonTextColor: Color
    var onUpdate: ((AbsenceEntry) -> Void)? = nil

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

        return VStack {
            Text(self.title)
                .font(.headline)
            Form {
                DisclosureGroup(
                    isExpanded: self.$isAbsenceTypeExpanded,
                    content: {
                        Picker("", selection: self.$absenceType) {
                            ForEach(self.absenceTypes, id: \.self) { absenceType in
                                HStack {
                                    Text(LocalizedStringKey(absenceType.title))
                                    Text(absenceType.icon)
                                }
                                .tag(absenceType)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .contentShape(Rectangle())
                        .onTapGesture {} // Note: Avoid closing on tap
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
                    Text("date")
                    Spacer()
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
            Button(action: {
                var newAbsenceEntry = self.absenceEntry
                newAbsenceEntry.update(type: self.absenceType,
                                       start: self.startDay,
                                       end: self.endDay)
                self.onUpdate?(newAbsenceEntry)

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
        .frame(maxHeight: self.isAbsenceTypeExpanded ? 500 : 270)
        .onAppear {
            self.absenceType = self.absenceEntry.type
            self.startDay = self.absenceEntry.start
            self.endDay = self.absenceEntry.end
        }
    }
}

struct AbsenceEntryEditView_Previews: PreviewProvider {
    static var previews: some View {
        AbsenceEntryEditView(absenceEntry: AbsenceEntry(type: AbsenceType(id: UUID(),
                                                                          title: "bankHoliday",
                                                                          icon: "🙌",
                                                                          offPercentage: 1),
                                                        start: Day(),
                                                        end: Day().addingDays(2)),
                             absenceTypes: SettingsState().absenceTypes,
                             title: "addAbsenceEntry",
                             buttonTitle: "add",
                             buttonTextColor: .white)
            .accentColor(.green)
            .environment(\.colorScheme, .dark)
            .background(Color.primary)
    }
}
