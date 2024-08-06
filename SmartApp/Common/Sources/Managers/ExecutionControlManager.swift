import Foundation
import UIKit

public extension Common {
    enum ExecutionControlManager {
        // Thread-safe storage for throttle timestamps
        @PWThreadSafe private static var throttleTimestamps: [String: TimeInterval] = [:]
        // Thread-safe storage for debounce timers
        @PWThreadSafe private static var debounceTimers: [String: Timer] = [:]

        /**
         Throttles the execution of a closure. The closure will only be executed if the specified time interval has elapsed since the last execution with the same operation ID.

         - Parameters:
            - timeInterval: The minimum time interval between successive executions.
            - operationId: A unique identifier for the operation being throttled.
            - closure: The closure to be executed.
            - onIgnoredClosure: An optional closure to be executed if the main closure is throttled.
         */
        public static func throttle(
            _ timeInterval: TimeInterval,
            operationId: String,
            closure: () -> Void,
            onIgnoredClosure: () -> Void = {}
        ) {
            let currentTime = Date().timeIntervalSince1970
            if let lastTimestamp = throttleTimestamps[operationId], currentTime - lastTimestamp < timeInterval {
                onIgnoredClosure()
                return
            }
            closure()
            throttleTimestamps[operationId] = currentTime
        }

        /**
         Debounces the execution of a closure. The closure will only be executed after the specified time interval has elapsed since the last call with the same operation ID.

         - Parameters:
            - timeInterval: The time interval to wait before executing the closure.
            - operationId: A unique identifier for the operation being debounced.
            - closure: The closure to be executed.
         */
        public static func debounce(
            _ timeInterval: TimeInterval,
            operationId: String,
            closure: @escaping () -> Void
        ) {
            // Invalidate any existing timer for the given operation ID
            debounceTimers[operationId]?.invalidate()
            // Schedule a new timer to execute the closure after the specified time interval
            let timer = Timer.scheduledTimer(
                withTimeInterval: timeInterval,
                repeats: false
            ) { _ in
                closure()
                debounceTimers[operationId] = nil
            }

            // Store the new timer
            debounceTimers[operationId] = timer
            
        }
    }
}

extension Common.ExecutionControlManager {
    /**
     Sample usage of the throttle and debounce functions.
     */
    static func sampleUsage() {
        print("do tests")
        // Throttle usage: the closure will only be executed if at least 1 second has passed since the last execution
        Common.ExecutionControlManager.throttle(1, operationId: "myClosure") {
            // "Executing closure..."
        }
        // Debounce usage: the closure will only be executed 1 second after the last call to debounce with this operation ID
        Common.ExecutionControlManager.debounce(1.0, operationId: "myDebouncedClosure") {
            // "Executing debounced closure..."
        }
    }
}
