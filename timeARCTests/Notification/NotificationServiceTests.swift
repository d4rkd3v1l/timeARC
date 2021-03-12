//
//  NotificationServiceTests.swift
//  timeARCTests
//
//  Created by d4Rk on 12.03.21.
//

import XCTest
import Resolver
@testable import timeARC

class NotificationServiceTests: XCTestCase {
    @Injected var notificationService: NotificationService

    override func setUpWithError() throws {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    override func tearDownWithError() throws {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func testScheduleEndOfWorkingDayNotification() throws {
        let timeEntries = try self.timeEntries()
        let targetDate = Date().addingTimeInterval(18_000)

        self.notificationService.scheduleEndOfWorkingDayNotification(for: timeEntries, workingDuration: 28_800)

        let exp = expectation(description: "Notification should be scheduled.")

        // Note: Need to delay this a bit, as the notifications are added asynchronously internally, due to requesting authorization is async as well.
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                guard let request = requests.first,
                      let trigger = request.trigger as? UNCalendarNotificationTrigger,
                      let nextTriggerDate = trigger.nextTriggerDate() else { return XCTFail() }

                XCTAssertEqual(nextTriggerDate.timeIntervalSinceReferenceDate,
                               targetDate.timeIntervalSinceReferenceDate,
                               accuracy: 1)

                exp.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testScheduleEndOfWorkingWeekNotification() throws {
        let timeEntries = try self.timeEntries()
        let weekday = try XCTUnwrap(Calendar.current.dateComponents([.weekday], from: Date()).weekday)
        let targetDate = Date().addingTimeInterval(18_000)

        self.notificationService.scheduleEndOfWorkingWeekNotification(for: timeEntries, workingDuration: 28_800, workingWeekDays:[WeekDay(weekday)])

        let exp = expectation(description: "Notification should be scheduled.")

        // Note: Need to delay this a bit, as the notifications are added asynchronously internally, due to requesting authorization is async as well.
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                guard let request = requests.first,
                      let trigger = request.trigger as? UNCalendarNotificationTrigger,
                      let nextTriggerDate = trigger.nextTriggerDate() else { return XCTFail() }

                XCTAssertEqual(request.identifier, NotificationService.endOfWorkingWeekNotificationIdentifier)
                XCTAssertEqual(nextTriggerDate.timeIntervalSinceReferenceDate,
                               targetDate.timeIntervalSinceReferenceDate,
                               accuracy: 1)

                exp.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Helper

    private func timeEntries() throws -> [Day: [TimeEntry]] {
        var timeEntries: [Day: [TimeEntry]] = [:]

        timeEntries[Day()] = [TimeEntry(start: try Date(hour: 8, minute: 0, second: 0),
                                        end: try Date(hour: 11, minute: 0, second: 0))]

        return timeEntries
    }
}
