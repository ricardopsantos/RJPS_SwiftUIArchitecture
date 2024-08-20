//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit

public extension Common {
    enum CronometerManager {
        /**
         * Common_CronometerManager.printTimeElapsedWhenRunningCode("nthPrimeNumber")
         * {
         *    log(Common_CronometerManager.nthPrimeNumber(10000))
         * }
         */
        @discardableResult
        public static func measure(operation: () -> Void, printResult: Bool = false) -> Double {
            let startTime = CFAbsoluteTimeGetCurrent()
            operation()
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            if printResult {
                LogsManager.debug("Time elapsed: \(timeElapsed)s")
            }
            return timeElapsed
        }

        public static func measureAverage(iterations: Int, operation: () -> Void, printResult: Bool = false) -> Double {
            let startTime = CFAbsoluteTimeGetCurrent()
            for _ in 1...iterations {
                operation()
            }
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            return timeElapsed / Double(iterations)
        }

        @PWThreadSafe private static var times: [String: CFAbsoluteTime] = [:]

        public static func startTimerWith(identifier: String? = "\(Common_CronometerManager.self)") {
            times.removeValue(forKey: identifier ?? "")
            times[identifier ?? ""] = CFAbsoluteTimeGetCurrent()
        }

        @discardableResult
        public static func timeElapsed(_ identifier: String? = "\(Common_CronometerManager.self)", print: Bool = false) -> Double? {
            var result: Double?
            let identifier = identifier ?? ""
            if let time = times[identifier] {
                let timeElapsed: Double = CFAbsoluteTimeGetCurrent() - time
                if print {
                    var timeElapsedString = ""
                    if timeElapsed > 1 {
                        timeElapsedString = String(format: "%.1f", timeElapsed)
                    } else if timeElapsed > 0.1 {
                        timeElapsedString = String(format: "%.2f", timeElapsed)
                    } else if timeElapsed > 0.01 {
                        timeElapsedString = String(format: "%.3f", timeElapsed)
                    } else {
                        timeElapsedString = String(format: "%.4f", timeElapsed)
                    }
                    // Ignore extra zeros
                    timeElapsedString = timeElapsedString.replacingOccurrences(of: "\\.?0*$", with: "", options: .regularExpression)
                    // let prefix = "            "
                    let prefix = "      "
                    LogsManager.debug("⏰ ⏰ Operation: \(identifier) ⏰ ⏰\n\(prefix)⏰ ⏰ Time: \(timeElapsedString) s ⏰ ⏰" as AnyObject)
                }
                result = Double(timeElapsed)
            }
            return result ?? 0
        }

        public static func remove(_ identifier: String) {
            times.removeValue(forKey: identifier)
        }
    }
}
