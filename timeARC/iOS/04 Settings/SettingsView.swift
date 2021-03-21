//
//  SettingsView.swift
//  timeARC
//
//  Created by d4Rk on 14.08.20.
//

import SwiftUI
import SwiftUIFlux

struct SettingsView: ConnectedView {
    @Environment(\.colorScheme) var colorScheme

    // TODO: Use .allCases (maybe sorted)
    private let colors: [CodableColor] = [.primary, .blue, .gray, .green, .orange, .pink, .purple, .red, .yellow]

    struct Props {
        let workingWeekDays: [WeekDay]
        let workingDurationBinding: Binding<Date>
        let workingWeekDaysBinding: Binding<[WeekDay]>
        let accentColorBinding: Binding<CodableColor>
        let updateWorkingWeekDays: ([WeekDay]) -> Void
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(workingWeekDays: state.settingsState.workingWeekDays,
                     workingDurationBinding:
                        Binding<Date>(get: { state.settingsState.workingDuration.hoursAndMinutes },
                                      set: { dispatch(UpdateWorkingDuration(workingDuration: $0.hoursAndMinutesInSeconds)) }),
                     workingWeekDaysBinding:
                        Binding<[WeekDay]>(get: { state.settingsState.workingWeekDays },
                                           set: { dispatch(UpdateWorkingWeekDays(workingWeekDays: $0)) }),
                     accentColorBinding:
                        Binding<CodableColor>(get: { state.settingsState.accentColor },
                                              set: { dispatch(UpdateAccentColor(color: $0, colorScheme: self.colorScheme)) }),
                     updateWorkingWeekDays: { dispatch(UpdateWorkingWeekDays(workingWeekDays: $0)) })
    }

    func body(props: Props) -> some View {
        NavigationView {
            Form {
                HStack {
                    Text("workingHours")
                        .accessibility(identifier: "Settings.workingHoursLabel")

                    DatePicker("", selection: props.workingDurationBinding, displayedComponents: .hourAndMinute)
                        .environment(\.locale, Locale(identifier: "de"))
                        .accessibility(identifier: "Settings.workingHours")
                }

                NavigationLink(destination: SettingsWeekDaysPicker(selections: props.workingWeekDaysBinding)) {
                    HStack {
                        Text("weekDays")
                        Spacer()
                        Text("\(props.workingWeekDaysBinding.wrappedValue.count)")
                    }
                }
                .accessibility(identifier: "Settings.weekDays")

                VStack(alignment: .leading) {
                    Text("accentColor")
                        .accessibility(identifier: "Settings.accentColorLabel")

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: [GridItem(.fixed(40))], alignment: .center, spacing: 10) {
                            ForEach(self.colors, id: \.self) { color in
                                Button(action: {
                                    props.accentColorBinding.wrappedValue = color
                                }, label: {
                                    AccentColorView(color: color,
                                                    isSelected: color == props.accentColorBinding.wrappedValue)
                                })
                                .accessibility(identifier: color.rawValue)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, -20)
                }
            }
            .navigationBarTitle("settings")
        }
    }
}

// MARK: - Preview

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
                .environmentObject(previewStore)
                .accentColor(.green)
                .colorScheme(.dark)
        }
    }
}
#endif
