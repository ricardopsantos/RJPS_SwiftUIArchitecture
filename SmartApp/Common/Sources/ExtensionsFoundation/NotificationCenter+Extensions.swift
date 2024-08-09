//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

public extension NotificationCenter {
    /**
     The purpose of this function is to allow you to observe notifications posted to the NotificationCenter for a specific notification name.
     When you call this function, it sets up an observer for the given notification name using NotificationCenter.default.addObserver.
     Whenever a notification with the specified name is posted, the closure provided to addObserver is called.

     In this case, the closure yields the object property of the notification object. This object can be of any type, hence the use of the Any? type.

     The AsyncStream type allows you to produce a stream of values asynchronously. In this case, the observeNotifications
     function returns an AsyncStream that produces a stream of values whenever the observer is triggered.

     The @discardableResult attribute is used to indicate that the return value of this function may be ignored
     without producing a compiler warning.

     Finally, the continuation.onTermination closure is called when the stream is closed. It removes the observer
     from the NotificationCenter to prevent any further notifications from being observed.
     */
    @discardableResult
    func observeNotifications(
        from notification: Notification.Name
    ) -> AsyncStream<Any?> {
        AsyncStream { continuation in
            let reference = NotificationCenter.default.addObserver(
                forName: notification,
                object: nil,
                queue: nil
            ) { some in
                continuation.yield(some.object)
            }

            continuation.onTermination = { @Sendable _ in
                NotificationCenter.default.removeObserver(reference)
            }
        }
    }
}

private func sampleUsageNotificationCenter() {
    // Define a notification name
    let myNotificationName = Notification.Name("MyNotification")

    // Create an observer for the notification
    let observer = NotificationCenter.default.observeNotifications(from: myNotificationName)

    // Asynchronously read values from the observer
    let task = Task {
        do {
            for try await value in observer {
                if let myObject = value {
                    // Do something with myObject
                    Common.LogsManager.debug("Received notification with object: \(myObject)")
                }
            }
        }
    }

    // Once you are done observing notifications, cancel the task to close the stream
    task.cancel()
}
