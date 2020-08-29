//
//  timetrackerApp.swift
//  watch Extension
//
//  Created by d4Rk on 23.08.20.
//

import SwiftUI

@main
struct timetrackerApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
//            NavigationView {
                ContentView()
//            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
