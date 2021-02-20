//
//  ListBla.swift
//  timeARC
//
//  Created by d4Rk on 19.02.21.
//

import SwiftUI
import SwiftUIFlux

struct ListTimeEntryCreateView: ConnectedView {
    let initialDay: Day

    @Environment(\.presentationMode) var presentationMode
    @State private var day: Day = Day()
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()

    struct Props {
        let addTimeEntry: (TimeEntry) -> Void
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(addTimeEntry: { dispatch(AddTimeEntry(timeEntry: $0)) })
    }

    func body(props: Props) -> some View {
        VStack {
            Form {
                HStack {
                    Text("date")

                    Spacer()

                    DatePicker("", selection: self.$day.date, displayedComponents: .date)
                        .labelsHidden()
                }
                HStack {
                    Text("time")

                    Spacer()

                    DatePicker("", selection: self.$startDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    Image(systemName: "arrow.right")
                    DatePicker("", selection: self.$endDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
            }

            Button("create", action: {
                guard let start = self.startDate.withDate(from: self.day.date),
                      let end = self.endDate.withDate(from: self.day.date) else { return }
                props.addTimeEntry(TimeEntry(start: start, end: end))
                self.presentationMode.wrappedValue.dismiss()
            })
            .buttonStyle(CTAStyle())
        }
        .navigationBarTitle("createTimeEntryTitle")
        .onAppear {
            self.day = self.initialDay
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ListAddTimeEntryView_Previews: PreviewProvider {
    static var previews: some View {
        ListTimeEntryCreateView(initialDay: Day())
            .environmentObject(previewStore)
            .accentColor(.green)
            .environment(\.colorScheme, .dark)
    }
}
#endif
