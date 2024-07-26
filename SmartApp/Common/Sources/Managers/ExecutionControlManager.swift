//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension Common {
    enum ExecutionControlManager {
        @PWThreadSafe private static var throttleTimestamps: [String: TimeInterval] = [:]
        @PWThreadSafe private static var debounceTimers: [String: Timer] = [:]
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

        public static func debounce(
            _ timeInterval: TimeInterval,
            operationId: String,
            closure: @escaping () -> Void
        ) {
            debounceTimers[operationId]?.invalidate()
            let timer = Timer.scheduledTimer(
                withTimeInterval: timeInterval,
                repeats: false
            ) { _ in
                closure()
                debounceTimers[operationId] = nil
            }

            debounceTimers[operationId] = timer
        }
    }
}

extension Common.ExecutionControlManager {
    static func sampleUsage() {
        Common.ExecutionControlManager.throttle(1, operationId: "myClosure") {
            // "Executing closure..."
        }
        Common.ExecutionControlManager.debounce(1.0, operationId: "myDebouncedClosure") {
            // "Executing debounced closure..."
        }
    }
}
