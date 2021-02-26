//
//  ListBla.swift
//  timeARC
//
//  Created by d4Rk on 19.02.21.
//

import SwiftUI
import SwiftUIFlux

struct ListAbsenceEntryUpdateView: ConnectedView {
    let absenceEntry: AbsenceEntry


    struct Props {
        let absenceTypes: [AbsenceType]
        let absenceEntryBinding: () -> Binding<AbsenceEntry>
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(absenceTypes: state.settingsState.absenceTypes,
                     absenceEntryBinding: {
                        Binding<AbsenceEntry>(get: { state.timeState.absenceEntries.first(where: { $0.id == self.absenceEntry.id })! }, // TODO: Fix crash on delete
                                              set: { dispatch(UpdateAbsenceEntry(absenceEntry: $0)) })
                     })
    }

    func body(props: Props) -> some View {
        VStack {
            Form {
                Picker("absenceType", selection: props.absenceEntryBinding().type) {
                    ForEach(props.absenceTypes) { absenceType in
                        Text(absenceType.localizedTitle)
                            .tag(absenceType)
                    }
                }
                DatePicker("from", selection: props.absenceEntryBinding().start.date, displayedComponents: .date)
                DatePicker("to", selection: props.absenceEntryBinding().end.date, displayedComponents: .date)
            }
        }
        .navigationBarTitle("updateAbsenceEntryTitle")
    }
}

// MARK: - Preview

#if DEBUG
struct ListAbsenceEntryUpdateView_Previews: PreviewProvider {
    static var previews: some View {
        ListAbsenceEntryUpdateView(absenceEntry: AbsenceEntry(type: .dummy, start: Day(), end: Day()))
            .environmentObject(previewStore)
            .accentColor(.green)
            .environment(\.colorScheme, .dark)
    }
}
#endif
