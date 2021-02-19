//
//  ListBla.swift
//  timeARC
//
//  Created by d4Rk on 19.02.21.
//

import SwiftUI
import SwiftUIFlux

struct ListAddAbsenceEntryView: ConnectedView {
    @Environment(\.presentationMode) var presentationMode
    @State private var absenceType: AbsenceType?
    @State private var startDay: Day = Day()
    @State private var endDay: Day = Day()

    let initialDay: Day

    struct Props {
        let absenceTypes: [AbsenceType]
        let addAbsenceEntry: (AbsenceEntry) -> Void
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(absenceTypes: state.settingsState.absenceTypes,
                     addAbsenceEntry: { dispatch(AddAbsenceEntry(absenceEntry: $0)) })
    }

    func body(props: Props) -> some View {
        NavigationView {
            VStack {
                Form {
                    Picker("absenceType", selection: self.$absenceType) {
                        ForEach(props.absenceTypes) { absenceType in
                            Text(absenceType.localizedTitle)
                                .tag(absenceType)
                        }
                    }

                    DatePicker("from", selection: self.$startDay.date, displayedComponents: .date)

                    DatePicker("to", selection: self.$endDay.date, displayedComponents: .date)
                }

                Button("add", action: {
                    guard let absenceType = self.absenceType else { return }
                    props.addAbsenceEntry(AbsenceEntry(type: absenceType, start: self.startDay, end: self.endDay))
                    self.presentationMode.wrappedValue.dismiss()
                })
                .buttonStyle(CTAStyle())
            }
            .navigationBarTitle("addAbsenceEntryTitle")
        }
        .onAppear {
            self.startDay = self.initialDay
            self.endDay = self.initialDay
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ListAddAbsenceEntryView_Previews: PreviewProvider {
    static var previews: some View {
        ListAddAbsenceEntryView(initialDay: Day())
            .environmentObject(previewStore)
            .accentColor(.green)
            .environment(\.colorScheme, .dark)
    }
}
#endif
