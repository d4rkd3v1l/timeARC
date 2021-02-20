//
//  ListBla.swift
//  timeARC
//
//  Created by d4Rk on 19.02.21.
//

import SwiftUI
import SwiftUIFlux

struct ListAbsenceEntryCreateView: ConnectedView {
    enum Mode {
        case create(initialDay: Day)
        case update(absenceEntry: AbsenceEntry)

        var title: LocalizedStringKey {
            switch self {
            case .create: return "createAbsenceEntryTitle"
            case .update: return "updateAbsenceEntryTitle"
            }
        }

        var buttonTitle: LocalizedStringKey {
            switch self {
            case .create: return "create"
            case .update: return "update"
            }
        }
    }

    let mode: Mode

    @Environment(\.presentationMode) var presentationMode
    @State private var absenceEntry: AbsenceEntry = AbsenceEntry(type: .dummy, start: Day(), end: Day())

    struct Props {
        let absenceTypes: [AbsenceType]
        let addAbsenceEntry: (AbsenceEntry) -> Void
        let updateAbsenceEntry: (AbsenceEntry) -> Void
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(absenceTypes: state.settingsState.absenceTypes,
                     addAbsenceEntry: { dispatch(AddAbsenceEntry(absenceEntry: $0)) },
                     updateAbsenceEntry: { dispatch(UpdateAbsenceEntry(absenceEntry: $0)) })
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

            Button(self.mode.buttonTitle, action: {
                guard self.absenceEntry.type != .dummy else { return } // TODO: "Unhack" this!
                switch self.mode {
                case .create:
                    props.addAbsenceEntry(self.absenceEntry)
                case .update:
                    props.updateAbsenceEntry(self.absenceEntry)
                }
                self.presentationMode.wrappedValue.dismiss()
            })
            .buttonStyle(CTAStyle())
        }
        .navigationBarTitle(self.mode.title)
        .onAppear {
            switch self.mode {
            case .create(let initialDay):
                self.absenceEntry = AbsenceEntry(type: .dummy, start: initialDay, end: initialDay)
            case .update(let absenceEntry):
                self.absenceEntry = absenceEntry
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ListAddAbsenceEntryView_Previews: PreviewProvider {
    static var previews: some View {
        ListAbsenceEntryCreateView(mode: .create(initialDay: Day()))
            .environmentObject(previewStore)
            .accentColor(.green)
            .environment(\.colorScheme, .dark)
    }
}
#endif
