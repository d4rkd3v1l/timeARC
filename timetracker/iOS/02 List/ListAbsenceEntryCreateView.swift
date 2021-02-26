//
//  ListBla.swift
//  timeARC
//
//  Created by d4Rk on 19.02.21.
//

import SwiftUI
import SwiftUIFlux

struct ListAbsenceEntryCreateView: ConnectedView {
    @Environment(\.presentationMode) var presentationMode
    @State private var absenceEntry: AbsenceEntry

    init(initialDay: Day) {
        _absenceEntry = State(initialValue: AbsenceEntry(type: .dummy, start: initialDay, end: initialDay))
    }

    struct Props {
        let absenceTypes: [AbsenceType]
        let addAbsenceEntry: (AbsenceEntry) -> Void
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(absenceTypes: state.settingsState.absenceTypes,
                     addAbsenceEntry: { dispatch(AddAbsenceEntry(absenceEntry: $0)) })
    }

    func body(props: Props) -> some View {
        VStack {
            Form {
                Picker("absenceType", selection: self.$absenceEntry.type) {
                    ForEach(props.absenceTypes) { absenceType in
                        Text(absenceType.localizedTitle)
                            .tag(absenceType)
                    }
                }
                DatePicker("from", selection: self.$absenceEntry.start.date, displayedComponents: .date)
                DatePicker("to", selection: self.$absenceEntry.end.date, displayedComponents: .date)
            }

            Button("create", action: {
                guard self.absenceEntry.type != .dummy else { return } // TODO: "Unhack" this!
                props.addAbsenceEntry(self.absenceEntry)
                self.presentationMode.wrappedValue.dismiss()
            })
            .buttonStyle(CTAStyle())
        }
        .navigationBarTitle("createAbsenceEntryTitle")
    }
}

// MARK: - Preview

#if DEBUG
struct ListAddAbsenceEntryView_Previews: PreviewProvider {
    static var previews: some View {
        ListAbsenceEntryCreateView(initialDay: Day())
            .environmentObject(previewStore)
            .accentColor(.green)
            .environment(\.colorScheme, .dark)
    }
}
#endif
