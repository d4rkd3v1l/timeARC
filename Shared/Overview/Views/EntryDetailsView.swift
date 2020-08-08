//
//  EntryDetails.swift
//  timetracker
//
//  Created by d4Rk on 21.07.20.
//

import SwiftUI
import SwiftUIFlux

struct EntryDetailsView: ConnectedView {
    struct Props {
        let timeEntries: [TimeEntry]
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(timeEntries: state.timeState.timeEntries.filter({ timeEntry in
            timeEntry.isRelevant(for: self.selectedDate)
        }))
    }

    let selectedDate: Date

    func body(props: Props) -> some View {
        VStack {
            Text(props.timeEntries.totalDurationInSeconds(on: self.selectedDate).formatted() ?? "")
            List(props.timeEntries) { timeEntry in
                Text("\(timeEntry.start.formatted("HH:mm")) - \(timeEntry.end?.formatted("HH:mm") ?? "now")")
                Spacer()
                Text(timeEntry.durationFormatted() ?? "")
            }.navigationTitle(self.selectedDate.formatted("MMM d, yyyy"))
        }
    }
}

// MARK: - Preview

struct EntryDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        store.dispatch(action: InitFlux())
        store.dispatch(action: ToggleTimer())
        return StoreProvider(store: store) {
            EntryDetailsView(selectedDate: Date())
                .accentColor(.green)
        }
    }
}

