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
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var isAbsenceTypeExpanded: Bool = false

    var body: some View {
        VStack {
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
                    DatePicker("", selection: self.$startDate, displayedComponents: .date)
                        .labelsHidden()
                        .onChange(of: self.startDate) { startDate in
                            if startDate > self.endDate {
                                self.startDate = self.endDate
                            }
                        }
                    Image(systemName: "arrow.right")
                    DatePicker("", selection: self.$endDate, displayedComponents: .date)
                        .labelsHidden()
                        .onChange(of: self.endDate) { endDate in
                            if endDate < self.startDate {
                                self.endDate = self.startDate
                            }
                        }
                }
            }
            Button(action: {
                var newAbsenceEntry = self.absenceEntry
                newAbsenceEntry.update(type: self.absenceType,
                                       startDate: self.startDate,
                                       endDate: self.endDate)
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
            self.startDate = self.absenceEntry.startDate
            self.endDate = self.absenceEntry.endDate
        }
    }
}

struct AbsenceEntryEditView_Previews: PreviewProvider {
    static var previews: some View {
        AbsenceEntryEditView(absenceEntry: AbsenceEntry(type: AbsenceType(id: UUID(),
                                                                          title: "bankHoliday",
                                                                          icon: "🙌",
                                                                          offPercentage: 1),
                                                        startDate: Date(),
                                                        endDate: Date().addingTimeInterval(216000)),
                             absenceTypes: SettingsState().absenceTypes,
                             title: "addAbsenceEntry",
                             buttonTitle: "add",
                             buttonTextColor: .white)
            .accentColor(.green)
            .environment(\.colorScheme, .dark)
            .background(Color.primary)
    }
}
