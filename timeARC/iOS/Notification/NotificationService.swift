//
//  NotificationService.swift
//  timeARC
//
//  Created by d4Rk on 28.02.21.
//

import SwiftUI

class NotificationService {
    static let endOfWoringDayNotificationIdentifier = "endOfWoringDayNotificationIdentifier"
    static let endOfWoringWeekNotificationIdentifier = "endOfWoringWeekNotificationIdentifier"

    func scheduleEndOfWorkingDayNotification(for timeEntries: [Day: [TimeEntry]], workingDuration: Int) {
        let currentDuration = timeEntries.forDay(Day()).totalDurationInSeconds
        let endOfWorkingDayDate = Date().addingTimeInterval(TimeInterval(workingDuration - currentDuration))

        removeNotifications(identifiers: [Self.endOfWoringDayNotificationIdentifier])
        scheduleNotification(with: NSLocalizedString("endOfWoringDayNotificationTitle", comment: ""),
                             body: NSLocalizedString("endOfWoringDayNotificationBody", comment: ""),
                             identifier: Self.endOfWoringDayNotificationIdentifier,
                             for: endOfWorkingDayDate)
    }

    func scheduleEndOfWorkingWeekNotification(for timeEntries: [Day: [TimeEntry]], workingDuration: Int, workingWeekDays: [WeekDay]) {
        let duration = timeEntries
            .filter { (Date().firstOfWeek...Date().lastOfWeek).contains($0.key.date) }
            .flatMap { $0.value }
            .totalDurationInSeconds

        let maxDuration = workingDuration * workingWeekDays.count
        let endOfWorkingWeekDate = Date().addingTimeInterval(TimeInterval(maxDuration - duration))

        removeNotifications(identifiers: [Self.endOfWoringWeekNotificationIdentifier])
        scheduleNotification(with: NSLocalizedString("endOfWoringWeekNotificationTitle", comment: ""),
                             body: NSLocalizedString("endOfWoringWeekNotificationBody", comment: ""),
                             identifier: Self.endOfWoringWeekNotificationIdentifier,
                             for: endOfWorkingWeekDate)
    }

    private func scheduleNotification(with title: String, body: String, identifier: String, for date: Date) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = UNNotificationSound.default

                let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                                            from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)

                let request = UNNotificationRequest(identifier: identifier,
                                                    content: content,
                                                    trigger: trigger)

                UNUserNotificationCenter.current().add(request)
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    func removeNotifications(identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
