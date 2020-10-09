//
//  ViewUpdater.swift
//  timetracker
//
//  Created by d4Rk on 09.10.20.
//

import Foundation
import Combine
import SwiftUIFlux

class ViewUpdater: ObservableObject {
    var subscriptions = Set<AnyCancellable>()

    init(updateInterval: TimeInterval) {
        Timer.publish(every: updateInterval,
                      on: .current,
                      in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.forceUpdate()
            }
            .store(in: &subscriptions)
    }

    func forceUpdate() {
        self.objectWillChange.send()
    }
}

class StateUpdater: ObservableObject {
    var subscriptions = Set<AnyCancellable>()

    init(updateInterval: TimeInterval, action: Action) {
        Timer.publish(every: updateInterval,
                      on: .current,
                      in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.forceUpdate(action: action)
            }
            .store(in: &subscriptions)
    }

    func forceUpdate(action: Action) {
        store.dispatch(action: action)
    }
}
