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

    struct Props {
        let workingWeekDays: [WeekDay]
        let workingMinutesPerDay: Int
        let accentColor: Color
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(workingWeekDays: state.settingsState.workingWeekDays,
                     workingMinutesPerDay: state.settingsState.workingMinutesPerDay,
                     accentColor: state.settingsState.accentColor.color)
    }

    @State private var workingHours: Date = Date().startOfDay.addingTimeInterval(28800)
    @StateObject private var expansionHandler = ExpansionHandler<ExpandableSection>()
    let colors: [Color] = [.primary, .blue, .gray, .green, .orange, .pink, .purple, .red, .yellow]

    func body(props: Props) -> some View {
        NavigationView {
            Form {
                DisclosureGroup(
                    isExpanded: self.expansionHandler.isExpanded(.workingHours),
                    content: {
                        DatePicker("", selection: self.$workingHours, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                            .contentShape(Rectangle())
                            .onTapGesture {} // Note: Avoid closing on tap
                            .onChange(of: self.workingHours) { time in
                                store.dispatch(action: UpdateWorkingMinutesPerDay(workingMinutesPerDay: time.hoursAndMinutesInMinutes))
                            }
                            .environment(\.locale, Locale(identifier: "de"))
                            .onAppear { self.workingHours = props.workingMinutesPerDay.hoursAndMinutes }
                    },
                    label: {
                        HStack {
                            Text("workingHours")
                            Spacer()
                            Text("\((props.workingMinutesPerDay * 60).formatted(allowedUnits: [.hour, .minute]) ?? "")")
                        }
                    }
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation { self.expansionHandler.toggleExpanded(for: .workingHours) }
                }

                DisclosureGroup(
                    isExpanded: self.expansionHandler.isExpanded(.weekDays),
                    content: {
                        MultipleValuesPickerView(initial: props.workingWeekDays)
                            .onSelectionChange { newSelections in
                                store.dispatch(action: UpdateWorkingWeekDays(workingWeekDays: newSelections))
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
                                        store.dispatch(action: UpdateAccentColor(color: color))
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.horizontal, -16)
                }
            }
            .navigationBarTitle("settings")
        }
    }
}

struct AccentColorView: View {
    @Environment(\.colorScheme) var colorScheme
    let color: Color
    let isSelected: Bool

    var body: some View {
        self.color
            .frame(width: 40, height: 40)
            .cornerRadius(10)
            .overlay(
                Image(systemName: self.isSelected ? "checkmark" : "")
                    .foregroundColor(self.color.contrastColor(for: self.colorScheme))
            )
    }
}

extension Color {
    func contrastColor(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .light:
            return self == .primary ? .white : .primary

        case .dark:
            return self == .primary ? .black : .primary

        @unknown default:
            return .primary
        }
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        store.dispatch(action: InitFlux())
        return Group {
            StoreProvider(store: store) {
                NavigationView {
                    SettingsView()
                        .accentColor(.green)
                }
            }
        }
    }
}

