//
//  StatisticsView.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 20.09.20.
//

import SwiftUI
import SwiftUIFlux

enum TimeFrame: String, CaseIterable, Identifiable, Codable {
    case all
    case year
    case month
    case week

    var id: String {
        return self.rawValue
    }
}

struct StatisticsView: ConnectedView {
    struct Props {
        
    }

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props()
    }

    @State private var selectedTimeFrame: TimeFrame = .all

    func body(props: Props) -> some View {
        NavigationView {
            VStack {
                Picker("", selection: self.$selectedTimeFrame) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                        Text(LocalizedStringKey(timeFrame.rawValue)).tag(timeFrame)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                HStack {
                    Button(action: {}, label: {
                        Image(systemName: "arrow.left.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                            .padding(.all, 15)
                    })

                    Text("02.10.2020 - 09.10.2020")

                    Button(action: {}, label: {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                            .padding(.all, 15)
                    })
                }

                List {
                    Section(header: Text("averages")) {
                        VStack {
                            HStack {
                                ArcViewFull(duration: 26900, maxDuration: 28800, color: .accentColor, allowedUnits: [.hour, .minute, .second], displayMode: .countUp)
                                    .frame(width: 150, height: 150)
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("workingHours")
                                    Spacer()
                                    Text("08:34 - 18:13")
                                }
                            }
                        }

                        HStack {
                            Text("breaks")
                            Spacer()
                            Text("0:35")
                        }

                        HStack {
                            Text("overtime")
                            Spacer()
                            Text("-0:14")
                        }
                    }

                    Section(header: Text("Totals")) {
                        VStack {
                            HStack {
                                ArcViewFull(duration: 4, maxDuration: 5, color: .accentColor, allowedUnits: [.second], displayMode: .progress)
                                    .frame(width: 150, height: 150)
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("daysWorked")
                                    Spacer()
                                }
                            }
                        }

                        HStack {
                            Text("workingHours")
                            Spacer()
                            Text("145:43")
                        }

                        HStack {
                            Text("breaks")
                            Spacer()
                            Text("4:34")
                        }

                        HStack {
                            Text("overtime")
                            Spacer()
                            Text("0:30")
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationBarTitle("statistics")
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        store.dispatch(action: InitFlux())

        return StoreProvider(store: store) {
            StatisticsView()
                .accentColor(.green)
                .environment(\.colorScheme, .dark)
        }
    }
}
