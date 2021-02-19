//
//  SettingsView.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 14.08.20.
//

import SwiftUI
import SwiftUIFlux

struct SettingsView: ConnectedView {
    enum ExpandableSection: Equatable {
        case workingHours
        case weekDays
    }

    private let colors: [CodableColor] = [.primary, .blue, .gray, .green, .orange, .pink, .purple, .red, .yellow]

    @Environment(\.colorScheme) var colorScheme
    @State private var workingHours: Date = Date().startOfDay.addingTimeInterval(28800)
    @StateObject private var expansionHandler = ExpansionHandler<ExpandableSection>()

    struct Props {
        let workingWeekDays: [WeekDay]
        let workingDuration: Int
        let accentColor: CodableColor
        let updateWorkingDuration: (Int) -> Void
        let updateWorkingWeekDays: ([WeekDay]) -> Void
        let updateAccentColor: (CodableColor) -> Void
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(workingWeekDays: state.settingsState.workingWeekDays,
                     workingDuration: state.settingsState.workingDuration,
                     accentColor: state.settingsState.accentColor,
                     updateWorkingDuration: { dispatch(UpdateWorkingDuration(workingDuration: $0)) },
                     updateWorkingWeekDays: { dispatch(UpdateWorkingWeekDays(workingWeekDays: $0)) },
                     updateAccentColor: { dispatch(UpdateAccentColor(color: $0, colorScheme: self.colorScheme)) })
    }

    func body(props: Props) -> some View {
        NavigationView {
            Form {
                HStack {
                    Text("workingHours")
                    DatePicker("", selection: self.$workingHours, displayedComponents: .hourAndMinute)
                        .onChange(of: self.workingHours) { time in
                            props.updateWorkingDuration(time.hoursAndMinutesInSeconds)
                        }
                        .environment(\.locale, Locale(identifier: "de"))
                        .onAppear { self.workingHours = props.workingDuration.hoursAndMinutes }
                }

                DisclosureGroup(
                    isExpanded: self.expansionHandler.isExpanded(.weekDays),
                    content: {
                        MultipleValuesPickerView(initial: props.workingWeekDays)
                            .onSelectionChange { newSelections in
                                props.updateWorkingWeekDays(newSelections)
                            }
                    },
                    label: {
                        HStack {
                            Text("weekDays")
                            Spacer()
                            Text("\(props.workingWeekDays.count)")
                        }
                    }
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation { self.expansionHandler.toggleExpanded(for: .weekDays) }
                }

                VStack(alignment: .leading) {
                    Text("accentColor")
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: [GridItem(.fixed(40))], alignment: .center, spacing: 10) {
                            ForEach(self.colors, id: \.self) { color in
                                AccentColorView(color: color,
                                                isSelected: color == props.accentColor)
                                    .onTapGesture {
                                        props.updateAccentColor(color)
                                    }
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

struct AccentColorView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let color: CodableColor
    let isSelected: Bool

    var body: some View {
        self.color.color
            .frame(width: 40, height: 40)
            .cornerRadius(10)
            .overlay(
                Image(systemName: self.isSelected ? "checkmark" : "")
                    .foregroundColor(self.color.contrastColor(for: self.colorScheme))
            )
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
