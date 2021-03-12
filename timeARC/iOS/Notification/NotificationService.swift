//
//  NotificationService.swift
//  timeARC
//
//  Created by d4Rk on 28.02.21.
//

import SwiftUI

class NotificationService {
    static let endOfWorkingDayNotificationIdentifier = "endOfWorkingDayNotificationIdentifier"
    static let endOfWorkingWeekNotificationIdentifier = "endOfWorkingWeekNotificationIdentifier"

    func scheduleEndOfWorkingDayNotification(for timeEntries: [Day: [TimeEntry]], workingDuration: Int) {
        let currentDuration = timeEntries.forDay(Day()).totalDurationInSeconds
        let endOfWorkingDayDate = Date().addingTimeInterval(TimeInterval(workingDuration - currentDuration))
        let request = UNNotificationRequest(title: NSLocalizedString("endOfWorkingDayNotificationTitle", comment: ""),
                                            body: NSLocalizedString("endOfWorkingDayNotificationBody", comment: ""),
                                            identifier: Self.endOfWorkingDayNotificationIdentifier,
                                            for: endOfWorkingDayDate)

        self.removeNotifications(identifiers: [Self.endOfWorkingDayNotificationIdentifier])
        self.scheduleNotification(for: request)
    }

    func scheduleEndOfWorkingWeekNotification(for timeEntries: [Day: [TimeEntry]], workingDuration: Int, workingWeekDays: [WeekDay]) {
        let duration = timeEntries
            .filter { (Date().firstOfWeek...Date().lastOfWeek).contains($0.key.date) }
            .flatMap { $0.value }
            .totalDurationInSeconds

        let maxDuration = workingDuration * workingWeekDays.count
        let endOfWorkingWeekDate = Date().addingTimeInterval(TimeInterval(maxDuration - duration))
        let request = UNNotificationRequest(title: NSLocalizedString("endOfWorkingWeekNotificationTitle", comment: ""),
                                            body: NSLocalizedString("endOfWorkingWeekNotificationBody", comment: ""),
                                            identifier: Self.endOfWorkingWeekNotificationIdentifier,
                                            for: endOfWorkingWeekDate)

        self.removeNotifications(identifiers: [Self.endOfWorkingWeekNotificationIdentifier])
        self.scheduleNotification(for: request)
    }

    func removeNotifications(identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func scheduleNotification(for request: UNNotificationRequest) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                UNUserNotificationCenter.current().add(request)
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}

private extension UNNotificationRequest {
    convenience init(title: String, body: String, identifier: String, for date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default

        let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                                    from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)

        self.init(identifier: identifier,
                  content: content,
                  trigger: trigger)
    }
}
